class NearbyDriver {
  String id;
  String slug;
  String name;
  String? distance;
  String? avatar;
  String ridesCount;

  NearbyDriver({
    this.id = "",
    this.slug = "",
    this.name = "",
    this.ridesCount = "",
  });

  NearbyDriver.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        slug = jsonMap['slug'] ?? '',
        name = jsonMap['name'] ?? '',
        distance = jsonMap['distance'],
        avatar = jsonMap['avatar'],
        ridesCount = jsonMap['rides_count'] ?? '';
}
