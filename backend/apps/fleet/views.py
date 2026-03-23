from django.db import transaction
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Hub, Vehicle, VehicleAllocation
from .serializers import (HubSerializer, VehicleSerializer,
                           VehicleAllocationSerializer, AllocateVehicleSerializer)
from apps.onboarding.models import Rider


class HubViewSet(viewsets.ModelViewSet):
    queryset = Hub.objects.annotate_counts() if hasattr(Hub.objects, 'annotate_counts') else Hub.objects.all()
    serializer_class = HubSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["city", "is_active"]


class VehicleViewSet(viewsets.ModelViewSet):
    queryset = Vehicle.objects.select_related("hub").all()
    serializer_class = VehicleSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["status", "hub", "vehicle_type"]

    @action(detail=False, methods=["get"])
    def available(self, request):
        hub = request.query_params.get("hub")
        qs = Vehicle.objects.filter(status=Vehicle.Status.AVAILABLE)
        if hub:
            qs = qs.filter(hub=hub)
        return Response(VehicleSerializer(qs, many=True).data)

    @action(detail=False, methods=["get"])
    def stats(self, request):
        from django.db.models import Count
        stats = Vehicle.objects.values("status").annotate(count=Count("id"))
        return Response(list(stats))


class VehicleAllocationViewSet(viewsets.ModelViewSet):
    queryset = VehicleAllocation.objects.select_related("vehicle", "rider__user").all()
    serializer_class = VehicleAllocationSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["status", "vehicle", "rider"]

    @action(detail=False, methods=["post"])
    @transaction.atomic
    def allocate(self, request):
        s = AllocateVehicleSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        d = s.validated_data
        vehicle = Vehicle.objects.select_for_update().get(id=d["vehicle_id"])
        rider = Rider.objects.get(id=d["rider_id"])
        if vehicle.status != Vehicle.Status.AVAILABLE:
            return Response({"error": "Vehicle not available"}, status=400)
        if rider.onboarding_status != "active":
            return Response({"error": "Rider must be active"}, status=400)
        if rider.allocations.filter(status="active").exists():
            return Response({"error": "Rider already has an active allocation"}, status=400)
        allocation = VehicleAllocation.objects.create(
            vehicle=vehicle, rider=rider,
            plan_type=d["plan_type"], start_date=d["start_date"],
            end_date=d.get("end_date"), daily_rent=d["daily_rent"],
            allocated_by=request.user, notes=d.get("notes", "")
        )
        vehicle.status = Vehicle.Status.ALLOCATED
        vehicle.save(update_fields=["status"])
        # Auto-create wallet dues
        from apps.payments.tasks import setup_rental_dues
        setup_rental_dues.delay(str(allocation.id))
        return Response(VehicleAllocationSerializer(allocation).data, status=201)

    @action(detail=True, methods=["post"])
    @transaction.atomic
    def return_vehicle(self, request, pk=None):
        allocation = self.get_object()
        if allocation.status != VehicleAllocation.AllocationStatus.ACTIVE:
            return Response({"error": "Allocation not active"}, status=400)
        from django.utils import timezone
        allocation.status = VehicleAllocation.AllocationStatus.RETURNED
        allocation.actual_return_date = timezone.now().date()
        allocation.save()
        vehicle = allocation.vehicle
        vehicle.status = Vehicle.Status.AVAILABLE
        vehicle.save(update_fields=["status"])
        return Response({"status": "returned"})
