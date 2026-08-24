import re

from django.contrib import admin
from django.conf import settings
from django.urls import include, path, re_path
from django.views.static import serve
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/auth/", include("apps.accounts.urls")),
    path("api/auth/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/departments/", include("apps.departments.urls")),
    path("api/complaints/", include("apps.complaints.urls")),
    path("api/reports/", include("apps.reports.urls")),
]

# WhiteNoise serves STATIC_ROOT only. django.conf.urls.static.static() is a
# no-op when DEBUG is False, so complaint uploads under MEDIA_ROOT would 404
# in the Docker/Gunicorn setup. Limit serving to MEDIA_URL -> MEDIA_ROOT.
_media_prefix = settings.MEDIA_URL.lstrip("/")
urlpatterns += [
    re_path(
        rf"^{re.escape(_media_prefix)}(?P<path>.*)$",
        serve,
        {"document_root": settings.MEDIA_ROOT},
    ),
]
