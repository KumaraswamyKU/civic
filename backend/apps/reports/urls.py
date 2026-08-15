from django.urls import path

from .views import DashboardSummaryView, ExportReportCSVView

urlpatterns = [
    path("summary/", DashboardSummaryView.as_view(), name="report-summary"),
    path("export/csv/", ExportReportCSVView.as_view(), name="report-export-csv"),
]
