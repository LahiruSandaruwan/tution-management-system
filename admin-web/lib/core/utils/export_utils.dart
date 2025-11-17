import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ExportUtils {
  /// Export data to CSV format
  static void exportToCSV({
    required List<Map<String, dynamic>> data,
    required List<String> headers,
    required List<String> keys,
    required String filename,
  }) {
    if (data.isEmpty) {
      return;
    }

    // Create CSV content
    final StringBuffer csvBuffer = StringBuffer();

    // Add headers
    csvBuffer.writeln(headers.join(','));

    // Add data rows
    for (final row in data) {
      final values = keys.map((key) {
        final value = _getNestedValue(row, key);
        final stringValue = value?.toString() ?? '';
        // Escape commas and quotes
        if (stringValue.contains(',') ||
            stringValue.contains('"') ||
            stringValue.contains('\n')) {
          return '"${stringValue.replaceAll('"', '""')}"';
        }
        return stringValue;
      }).toList();
      csvBuffer.writeln(values.join(','));
    }

    // Create and download file
    _downloadFile(
      content: csvBuffer.toString(),
      filename: '$filename.csv',
      mimeType: 'text/csv',
    );
  }

  /// Export data to JSON format (can be opened in Excel)
  static void exportToJSON({
    required List<Map<String, dynamic>> data,
    required String filename,
  }) {
    if (data.isEmpty) {
      return;
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    _downloadFile(
      content: jsonString,
      filename: '$filename.json',
      mimeType: 'application/json',
    );
  }

  /// Export data to Excel-compatible HTML format
  static void exportToExcel({
    required List<Map<String, dynamic>> data,
    required List<String> headers,
    required List<String> keys,
    required String filename,
  }) {
    if (data.isEmpty) {
      return;
    }

    final StringBuffer htmlBuffer = StringBuffer();
    htmlBuffer.writeln('<html>');
    htmlBuffer.writeln('<head>');
    htmlBuffer.writeln('<meta charset="UTF-8">');
    htmlBuffer.writeln('<style>');
    htmlBuffer.writeln('table { border-collapse: collapse; width: 100%; }');
    htmlBuffer.writeln(
        'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }');
    htmlBuffer.writeln('th { background-color: #1976D2; color: white; }');
    htmlBuffer.writeln('tr:nth-child(even) { background-color: #f2f2f2; }');
    htmlBuffer.writeln('</style>');
    htmlBuffer.writeln('</head>');
    htmlBuffer.writeln('<body>');
    htmlBuffer.writeln('<table>');

    // Add headers
    htmlBuffer.writeln('<thead><tr>');
    for (final header in headers) {
      htmlBuffer.writeln('<th>$header</th>');
    }
    htmlBuffer.writeln('</tr></thead>');

    // Add data rows
    htmlBuffer.writeln('<tbody>');
    for (final row in data) {
      htmlBuffer.writeln('<tr>');
      for (final key in keys) {
        final value = _getNestedValue(row, key);
        htmlBuffer.writeln('<td>${value ?? ''}</td>');
      }
      htmlBuffer.writeln('</tr>');
    }
    htmlBuffer.writeln('</tbody>');

    htmlBuffer.writeln('</table>');
    htmlBuffer.writeln('</body>');
    htmlBuffer.writeln('</html>');

    _downloadFile(
      content: htmlBuffer.toString(),
      filename: '$filename.xls',
      mimeType: 'application/vnd.ms-excel',
    );
  }

  /// Helper method to get nested values from maps
  static dynamic _getNestedValue(Map<String, dynamic> map, String key) {
    if (!key.contains('.')) {
      return map[key];
    }

    final keys = key.split('.');
    dynamic value = map;
    for (final k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }

  /// Helper method to download file in browser
  static void _downloadFile({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
