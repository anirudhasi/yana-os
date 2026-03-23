from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    # Auth
    path("api/auth/", include("apps.core.urls")),
    # Modules
    path("api/onboarding/", include("apps.onboarding.urls")),
    path("api/fleet/", include("apps.fleet.urls")),
    path("api/payments/", include("apps.payments.urls")),
    path("api/marketplace/", include("apps.marketplace.urls")),
    path("api/sales/", include("apps.sales.urls")),
    path("api/maintenance/", include("apps.maintenance.urls")),
    path("api/support/", include("apps.support.urls")),
    path("api/skilldev/", include("apps.skilldev.urls")),
]
