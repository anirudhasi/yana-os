from rest_framework import serializers
from .models import Rider, RiderDocument, OnboardingEvent
from apps.core.serializers import UserSerializer


class RiderDocumentSerializer(serializers.ModelSerializer):
    presigned_url = serializers.SerializerMethodField()

    class Meta:
        model = RiderDocument
        fields = ["id", "doc_type", "verification_status", "presigned_url",
                  "rejection_note", "uploaded_at", "verified_at"]

    def get_presigned_url(self, obj):
        # Generate presigned S3/MinIO URL
        return f"/api/onboarding/documents/{obj.id}/download/"


class RiderListSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    hub_name = serializers.CharField(source="hub.name", read_only=True)
    documents_count = serializers.IntegerField(source="documents.count", read_only=True)

    class Meta:
        model = Rider
        fields = ["id", "user", "onboarding_status", "hub_name",
                  "seriousness_score", "documents_count", "created_at"]


class RiderDetailSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    documents = RiderDocumentSerializer(many=True, read_only=True)
    hub_name = serializers.CharField(source="hub.name", read_only=True)

    class Meta:
        model = Rider
        fields = ["id", "user", "aadhaar_number", "dl_number", "dl_expiry",
                  "bank_account", "ifsc_code", "bank_name", "onboarding_status",
                  "seriousness_score", "rejection_reason", "verified_at",
                  "activated_at", "hub_name", "documents", "created_at", "updated_at"]


class RiderCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rider
        fields = ["aadhaar_number", "dl_number", "dl_expiry",
                  "bank_account", "ifsc_code", "bank_name", "hub"]


class DocumentUploadSerializer(serializers.Serializer):
    doc_type = serializers.ChoiceField(choices=RiderDocument.DocType.choices)
    file = serializers.FileField()


class VerifyRiderSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=["approve", "reject"])
    rejection_reason = serializers.CharField(required=False, allow_blank=True)


class OnboardingEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = OnboardingEvent
        fields = "__all__"
