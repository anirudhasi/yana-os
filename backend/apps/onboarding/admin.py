from django.contrib import admin
from .models import Rider, RiderDocument, OnboardingEvent

@admin.register(Rider)
class RiderAdmin(admin.ModelAdmin):
    list_display = ["user", "onboarding_status", "hub", "created_at"]
    list_filter = ["onboarding_status", "hub"]
    search_fields = ["user__full_name", "user__phone_number"]

admin.site.register(RiderDocument)
admin.site.register(OnboardingEvent)
