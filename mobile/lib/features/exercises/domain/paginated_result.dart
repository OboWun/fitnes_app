class PaginatedResult<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResult({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
