from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import LoginSerializer, SignupSerializer, UserSerializer


class SignupView(generics.CreateAPIView):
    """Public endpoint: citizen self-registration (name, email, phone, password)."""

    serializer_class = SignupSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(TokenObtainPairView):
    """Login with email OR phone number + password (citizens and dept admins)."""

    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)
