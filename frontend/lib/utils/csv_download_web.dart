import 'dart:html' as html;

Future<void> downloadCsvFile(List<int> bytes, {String filename = 'civic_issue_report.csv'}) async {
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
