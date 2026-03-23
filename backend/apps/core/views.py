import random
from datetime import timedelta
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User, OTPVerification
from .serializers import OTPRequestSerializer, OTPVerifySerializer, UserSerializer


@api_view(["POST"])
@permission_classes([AllowAny])
def request_otp(request):
    s = OTPRequestSerializer(data=request.data)
    s.is_valid(raise_exception=True)
    phone = s.validated_data["phone_number"]
    otp = str(random.randint(100000, 999999))
    OTPVerification.objects.create(
        phone_number=phone, otp=otp,
        expires_at=timezone.now() + timedelta(minutes=10)
    )
    # TODO: Send via Firebase / SMS gateway
    return Response({"message": "OTP sent", "debug_otp": otp if True else None})


@api_view(["POST"])
@permission_classes([AllowAny])
def verify_otp(request):
    s = OTPVerifySerializer(data=request.data)
    s.is_valid(raise_exception=True)
    phone = s.validated_data["phone_number"]
    otp = s.validated_data["otp"]
    record = OTPVerification.objects.filter(
        phone_number=phone, otp=otp, is_verified=False,
        expires_at__gte=timezone.now()
    ).last()
    if not record:
        return Response({"error": "Invalid or expired OTP"}, status=400)
    record.is_verified = True
    record.save()
    user, _ = User.objects.get_or_create(phone_number=phone, defaults={"full_name": phone})
    refresh = RefreshToken.for_user(user)
    return Response({
        "access": str(refresh.access_token),
        "refresh": str(refresh),
        "user": UserSerializer(user).data,
    })


@api_view(["GET"])
def me(request):
    return Response(UserSerializer(request.user).data)
