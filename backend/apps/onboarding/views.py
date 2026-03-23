from django.utils import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from .models import Rider, RiderDocument, OnboardingEvent
from .serializers import (RiderListSerializer, RiderDetailSerializer,
                           RiderCreateSerializer, DocumentUploadSerializer,
                           VerifyRiderSerializer, OnboardingEventSerializer)
from .tasks import send_kyc_notification, run_kyc_verification


class RiderViewSet(viewsets.ModelViewSet):
    queryset = Rider.objects.select_related("user", "hub").prefetch_related("documents")
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["onboarding_status", "hub"]

    def get_serializer_class(self):
        if self.action == "list":
            return RiderListSerializer
        if self.action == "create":
            return RiderCreateSerializer
        return RiderDetailSerializer

    def create(self, request):
        s = RiderCreateSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        rider, created = Rider.objects.get_or_create(
            user=request.user, defaults=s.validated_data
        )
        if not created:
            for k, v in s.validated_data.items():
                setattr(rider, k, v)
            rider.save()
        OnboardingEvent.objects.create(
            rider=rider, event_type="profile_updated",
            from_status="", to_status=rider.onboarding_status,
            performed_by=request.user
        )
        return Response(RiderDetailSerializer(rider).data, status=201)

    @action(detail=True, methods=["post"], parser_classes=[MultiPartParser, FormParser])
    def upload_document(self, request, pk=None):
        rider = self.get_object()
        s = DocumentUploadSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        doc_type = s.validated_data["doc_type"]
        file_obj = s.validated_data["file"]
        from django.core.files.storage import default_storage
        key = f"riders/{rider.id}/docs/{doc_type}/{file_obj.name}"
        saved_path = default_storage.save(key, file_obj)
        doc, _ = RiderDocument.objects.update_or_create(
            rider=rider, doc_type=doc_type,
            defaults={"s3_key": saved_path, "verification_status": "pending"}
        )
        mandatory = {"aadhaar", "dl", "photo"}
        uploaded = set(rider.documents.values_list("doc_type", flat=True))
        if mandatory.issubset(uploaded):
            rider.onboarding_status = Rider.OnboardingStatus.DOCS_SUBMITTED
            rider.save()
            run_kyc_verification.delay(str(rider.id))
        return Response({"message": "Document uploaded", "status": rider.onboarding_status})

    @action(detail=True, methods=["post"])
    def verify(self, request, pk=None):
        rider = self.get_object()
        s = VerifyRiderSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        old_status = rider.onboarding_status
        if s.validated_data["action"] == "approve":
            rider.onboarding_status = Rider.OnboardingStatus.KYC_VERIFIED
            rider.verified_by = request.user
            rider.verified_at = timezone.now()
        else:
            rider.onboarding_status = Rider.OnboardingStatus.REJECTED
            rider.rejection_reason = s.validated_data.get("rejection_reason", "")
        rider.save()
        OnboardingEvent.objects.create(
            rider=rider, event_type="kyc_decision",
            from_status=old_status, to_status=rider.onboarding_status,
            performed_by=request.user,
            notes=s.validated_data.get("rejection_reason", "")
        )
        send_kyc_notification.delay(str(rider.id), s.validated_data["action"])
        return Response({"status": rider.onboarding_status})

    @action(detail=True, methods=["post"])
    def activate(self, request, pk=None):
        rider = self.get_object()
        if rider.onboarding_status != Rider.OnboardingStatus.KYC_VERIFIED:
            return Response({"error": "Rider must be KYC verified first"}, status=400)
        rider.onboarding_status = Rider.OnboardingStatus.ACTIVE
        rider.activated_at = timezone.now()
        rider.save()
        return Response({"status": "active"})

    @action(detail=True, methods=["get"])
    def events(self, request, pk=None):
        rider = self.get_object()
        events = rider.events.all()
        return Response(OnboardingEventSerializer(events, many=True).data)

    @action(detail=False, methods=["get"])
    def stats(self, request):
        from django.db.models import Count
        stats = Rider.objects.values("onboarding_status").annotate(count=Count("id"))
        return Response(list(stats))
