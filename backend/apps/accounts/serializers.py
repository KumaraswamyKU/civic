from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.db.models import Q
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


class SignupSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])

    class Meta:
        model = User
        fields = ["id", "full_name", "email", "phone_number", "password"]

    def create(self, validated_data):
        user = User(
            username=validated_data["email"],
            full_name=validated_data["full_name"],
            email=validated_data["email"],
            phone_number=validated_data["phone_number"],
            role=User.Role.CITIZEN,
        )
        user.set_password(validated_data["password"])
        user.save()
        return user


class UserSerializer(serializers.ModelSerializer):
    department_name = serializers.CharField(source="department.name", read_only=True)

    class Meta:
        model = User
        fields = [
            "id", "full_name", "email", "phone_number", "role", "department", "department_name",
        ]


class LoginSerializer(TokenObtainPairSerializer):
    """
    Allows login with either email OR phone number in the same
    'identifier' field, plus password. Overrides the default
    username-only behaviour of SimpleJWT.
    """

    username_field = "identifier"

    def validate(self, attrs):
        identifier = attrs.get("identifier")
        password = attrs.get("password")
        try:
            user = User.objects.get(Q(email=identifier) | Q(phone_number=identifier))
        except User.DoesNotExist:
            raise serializers.ValidationError("No account found with that email/phone number.")

        if not user.check_password(password):
            raise serializers.ValidationError("Incorrect password.")
        if not user.is_active:
            raise serializers.ValidationError("This account is inactive.")

        refresh = self.get_token(user)
        return {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": UserSerializer(user).data,
        }

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        token["department_id"] = user.department_id
        return token
