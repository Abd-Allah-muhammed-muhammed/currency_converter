/// Model representing API error information.
class ApiErrorModel {
  /// Creates an API error model.
  const ApiErrorModel({required this.message, this.code});

  /// Factory to create from JSON response.
  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['message'] as String?,
      code: json['code'] as int?,
    );
  }

  /// The error message.
  final String? message;

  /// The error code.
  final int? code;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message, 'code': code};
  }
}
