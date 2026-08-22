/// Records eq / inFilter / order / limit from existing table `queryFn` lambdas.
class ShowcaseQuery {
  final Map<String, dynamic> equals = {};
  final Map<String, dynamic> notEquals = {};
  final Map<String, List<dynamic>> inFilters = {};
  String? orderColumn;
  bool ascending = true;
  int? limitCount;
  int? offsetCount;

  ShowcaseQuery eq(String column, dynamic value) {
    equals[column] = value;
    return this;
  }

  ShowcaseQuery neq(String column, dynamic value) {
    notEquals[column] = value;
    return this;
  }

  ShowcaseQuery inFilter(String column, List<dynamic> values) {
    inFilters[column] = values;
    return this;
  }

  ShowcaseQuery order(String column, {bool ascending = true}) {
    orderColumn = column;
    this.ascending = ascending;
    return this;
  }

  ShowcaseQuery limit(int count) {
    limitCount = count;
    return this;
  }

  ShowcaseQuery range(int from, int to) {
    offsetCount = from;
    limitCount = to - from + 1;
    return this;
  }

  ShowcaseQuery like(String column, String pattern) => this;
  ShowcaseQuery ilike(String column, String pattern) => this;
  ShowcaseQuery gt(String column, dynamic value) => this;
  ShowcaseQuery gte(String column, dynamic value) => this;
  ShowcaseQuery lt(String column, dynamic value) => this;
  ShowcaseQuery lte(String column, dynamic value) => this;
  ShowcaseQuery isFilter(String column, dynamic value) => this;
  ShowcaseQuery match(Map<dynamic, dynamic> query) => this;
  ShowcaseQuery not(String column, String operator, dynamic value) => this;
  ShowcaseQuery filter(String column, String operator, dynamic value) => this;
  ShowcaseQuery contains(String column, dynamic value) => this;
  ShowcaseQuery overlaps(String column, dynamic value) => this;
  ShowcaseQuery textSearch(String column, String query) => this;
  ShowcaseQuery or(String filter) => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => this;
}
