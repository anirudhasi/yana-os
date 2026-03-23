from config.celery import app
import logging
logger = logging.getLogger(__name__)


@app.task(bind=True, max_retries=3)
def send_kyc_notification(self, rider_id: str, decision: str):
    """Send WhatsApp + push notification on KYC outcome."""
    try:
        from .models import Rider
        rider = Rider.objects.select_related("user").get(id=rider_id)
        msg = (f"Congratulations {rider.user.full_name}! Your KYC is verified."
               if decision == "approve"
               else f"Your KYC application requires attention. Please contact support.")
        logger.info(f"[KYC Notification] Rider {rider_id}: {msg}")
        # TODO: integrate Firebase FCM + WhatsApp
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)


@app.task(bind=True, max_retries=2)
def run_kyc_verification(self, rider_id: str):
    """Auto-verify documents via Digilocker/Karza API."""
    try:
        from .models import Rider
        rider = Rider.objects.get(id=rider_id)
        rider.onboarding_status = Rider.OnboardingStatus.KYC_PENDING
        rider.save()
        # TODO: Call Karza/Digilocker API for Aadhaar + DL verification
        logger.info(f"[KYC] Auto-verification started for rider {rider_id}")
    except Exception as exc:
        raise self.retry(exc=exc, countdown=120)
