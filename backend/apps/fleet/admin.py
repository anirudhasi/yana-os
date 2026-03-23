from django.contrib import admin
from .models import Hub, Vehicle, VehicleAllocation

@admin.register(Hub)
class HubAdmin(admin.ModelAdmin):
    list_display = ["name", "city", "is_active"]

@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ["registration_number", "model", "hub", "status", "battery_health_pct"]
    list_filter = ["status", "hub", "vehicle_type"]

@admin.register(VehicleAllocation)
class VehicleAllocationAdmin(admin.ModelAdmin):
    list_display = ["vehicle", "rider", "plan_type", "start_date", "status"]
