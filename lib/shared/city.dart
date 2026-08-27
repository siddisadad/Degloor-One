class City {
  const City({
    required this.id,
    required this.name,
    this.state,
    this.district,
  });

  final String id;
  final String name;
  final String? state;
  final String? district;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      state: json['state'] as String?,
      district: json['district'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (state != null) 'state': state,
        if (district != null) 'district': district,
      };
}
