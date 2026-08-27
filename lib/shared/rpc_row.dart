import 'dart:convert';

/// Normalize a PostgREST RPC result that returns one table row.
Map<String, dynamic>? asRpcRow(dynamic response) {
  if (response is String) {
    final text = response.trim();
    if (text.startsWith('{') || text.startsWith('[')) {
      try {
        return asRpcRow(jsonDecode(text));
      } catch (_) {
        return null;
      }
    }
    return null;
  }
  if (response is Map<String, dynamic>) return response;
  if (response is Map) return Map<String, dynamic>.from(response);
  if (response is List && response.isNotEmpty) {
    final first = response.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }
  return null;
}

/// Strip ILIKE wildcards so a title search cannot match every row.
String sanitizeIlike(String raw) {
  return raw.trim().replaceAll(RegExp(r'[%_*]'), '');
}
