class SweetMessageApiResponse<T> {
  SweetMessageApiResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  final String status;
  final int code;
  final String message;
  final T? data;

  bool get isSuccess => status == 'success' && code == 200;

  factory SweetMessageApiResponse.fromMap(
      Map<String, dynamic> map,
      T? Function(dynamic data) parser,
      ) {
    return SweetMessageApiResponse<T>(
      status: (map['status'] ?? '').toString(),
      code: int.tryParse((map['code'] ?? '0').toString()) ?? 0,
      message: (map['message'] ?? '').toString(),
      data: parser(map['data']),
    );
  }
}