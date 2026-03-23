from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework import viewsets
from .models import Wallet, Transaction
from rest_framework import serializers

class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wallet
        fields = "__all__"

class WalletViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Wallet.objects.all()
    serializer_class = WalletSerializer

router = DefaultRouter()
router.register("wallets", WalletViewSet)

from django.urls import include
urlpatterns = [path("", include(router.urls))]
