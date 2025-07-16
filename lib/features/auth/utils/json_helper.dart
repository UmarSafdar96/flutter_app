// utils/json_helper.dart

class JSONHelper {
  final Map<String, dynamic> _json;

  JSONHelper(dynamic data)
      : _json = data is Map<String, dynamic> ? data : {};

  String? string(String key) => _json[key]?.toString();
  bool boolValue(String key) => _json[key] == true;
  dynamic get(String key) => _json[key];

  JSONHelper nested(String key) {
    final nestedMap = _json[key];
    if (nestedMap is Map<String, dynamic>) {
      return JSONHelper(nestedMap);
    }
    return JSONHelper({});
  }
}
