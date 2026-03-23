from rest_framework import serializers
from .models import Hub, Vehicle, VehicleAllocation


class HubSerializer(serializers.ModelSerializer):
    vehicle_count = serializers.IntegerField(source="vehicles.count", read_only=True)
    rider_count = serializers.IntegerField(source="riders.count", read_only=True)

    class Meta:
        model = Hub
        fields = "__all__"


class VehicleSerializer(serializers.ModelSerializer):
    hub_name = serializers.CharField(source="hub.name", read_only=True)

    class Meta:
        model = Vehicle
        fields = "__all__"


class VehicleAllocationSerializer(serializers.ModelSerializer):
    vehicle_reg = serializers.CharField(source="vehicle.registration_number", read_only=True)
    rider_name = serializers.CharField(source="rider.user.full_name", read_only=True)
    rider_phone = serializers.CharField(source="rider.user.phone_number", read_only=True)

    class Meta:
        model = VehicleAllocation
        fields = "__all__"


class AllocateVehicleSerializer(serializers.Serializer):
    vehicle_id = serializers.UUIDField()
    rider_id = serializers.UUIDField()
    plan_type = serializers.ChoiceField(choices=VehicleAllocation.PlanType.choices)
    start_date = serializers.DateField()
    end_date = serializers.DateField(required=False, allow_null=True)
    daily_rent = serializers.DecimalField(max_digits=10, decimal_places=2)
    notes = serializers.CharField(required=False, allow_blank=True)
