class Promotion {
  final String id;
  final String code;
  final String description;
  final double value;
  final double valueLimit;
  final DateTime beginning;
  final DateTime expiration;

  Promotion({
    required this.id,
    required this.code,
    required this.description,
    required this.value,
    required this.valueLimit,
    required this.beginning,
    required this.expiration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'value': value,
      'value_limit': valueLimit,
      'beginning': _formatDateTime(beginning),
      'expiration': _formatDateTime(expiration),
    };
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      valueLimit: double.tryParse(json['value_limit'].toString()) ?? 0.0,
      beginning: json['beginning'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['beginning']['_seconds'] * 1000)
          : DateTime.now(),
      expiration: json['expiration'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiration']['_seconds'] * 1000)
          : DateTime.now(),
    );
  }




  static String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
