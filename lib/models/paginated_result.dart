class PaginatedResult<T> {
  final int pageNumber;
  final int pageSize;
  final int count;
  final List<T> data;

  PaginatedResult({
    required this.pageNumber,
    required this.pageSize,
    required this.count,
    required this.data,
  });

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResult(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      count: json['count'],
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
    );
  }
}
