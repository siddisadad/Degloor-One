/// Offset pagination used by order and notification lists.
class PageQuery {
  const PageQuery({this.limit = 20, this.offset = 0});

  final int limit;
  final int offset;

  int get from => offset;
  int get to => offset + limit - 1;

  PageQuery next() => PageQuery(limit: limit, offset: offset + limit);
}

class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}
