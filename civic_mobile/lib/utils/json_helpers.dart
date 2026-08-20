int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? asNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  return asDouble(value);
}

DateTime? asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

Map<String, int> asCountMap(dynamic value) {
  if (value is! Map) {
    return {};
  }
  return value.map((key, count) => MapEntry(key.toString(), asInt(count)));
}
