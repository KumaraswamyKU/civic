import '../utils/csv_download_stub.dart'
    if (dart.library.html) '../utils/csv_download_web.dart' as impl;

Future<void> downloadCsvFile(List<int> bytes, {String filename = 'civic_issue_report.csv'}) {
  return impl.downloadCsvFile(bytes, filename: filename);
}
