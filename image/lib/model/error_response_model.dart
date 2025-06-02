class ApiErrorResponse {
  final String? id;
  final ApiError? error;

  ApiErrorResponse({
    this.id,
    this.error,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      id: json['id'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'error': error?.toJson(),
  };
}

class ApiError {
  final String? message;
  final String? type;
  final dynamic param;
  final dynamic code;

  ApiError({
    this.message,
    this.type,
    this.param,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'],
      type: json['type'],
      param: json['param'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'type': type,
    'param': param,
    'code': code,
  };
}
