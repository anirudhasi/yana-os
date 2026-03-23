from config.celery import app
import logging
logger = logging.getLogger(__name__)

@app.task
def setup_rental_dues(allocation_id: str):
    """Create wallet and set pending dues when vehicle allocated."""
    from fleet.models import VehicleAllocation
    from .models import Wallet
    try:
        alloc = VehicleAllocation.objects.select_related("rider").get(id=allocation_id)
        wallet, _ = Wallet.objects.get_or_create(rider=alloc.rider)
        wallet.pending_dues += alloc.daily_rent
        wallet.save()
    except Exception as e:
        logger.error(f"setup_rental_dues failed: {e}")

@app.task
def process_daily_rent_collection():
    """Daily cron: debit rent from active allocations."""
    from fleet.models import VehicleAllocation
    from .models import Wallet, Transaction
    from django.utils import timezone
    active = VehicleAllocation.objects.filter(status="active").select_related("rider")
    for alloc in active:
        wallet, _ = Wallet.objects.get_or_create(rider=alloc.rider)
        Transaction.objects.create(
            wallet=wallet, txn_type="rent_debit",
            amount=alloc.daily_rent, status="success",
            metadata={"allocation_id": str(alloc.id), "date": str(timezone.now().date())}
        )
        wallet.pending_dues += alloc.daily_rent
        wallet.save()
