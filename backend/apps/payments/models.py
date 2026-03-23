import uuid
from django.db import models
from django.conf import settings


class Wallet(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    rider = models.OneToOneField("onboarding.Rider", on_delete=models.CASCADE, related_name="wallet")
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    pending_dues = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_incentives_earned = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "wallets"


class Transaction(models.Model):
    class TxnType(models.TextChoices):
        RENT_DEBIT = "rent_debit", "Rent Debit"
        WALLET_TOPUP = "wallet_topup", "Wallet Top-up"
        INCENTIVE_CREDIT = "incentive_credit", "Incentive Credit"
        REFUND = "refund", "Refund"
        PENALTY = "penalty", "Penalty"

    class TxnStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        SUCCESS = "success", "Success"
        FAILED = "failed", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet = models.ForeignKey(Wallet, on_delete=models.PROTECT, related_name="transactions")
    txn_type = models.CharField(max_length=30, choices=TxnType.choices)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    reference_id = models.CharField(max_length=200, blank=True)
    gateway = models.CharField(max_length=50, blank=True)
    status = models.CharField(max_length=20, choices=TxnStatus.choices, default=TxnStatus.PENDING)
    metadata = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "transactions"
        ordering = ["-created_at"]
