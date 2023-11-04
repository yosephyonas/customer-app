class Media {
  String id;
  String name;
  String fileName;
  String url;
  String thumb;
  String icon;
  String size;
  String mimeType;

  Media({
    this.id = "",
    this.name = "",
    this.fileName = "",
    this.url = "",
    this.thumb = "",
    this.icon = "",
    this.size = "",
    this.mimeType = "",
  });

  Media.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name']?.toString() ?? '',
        fileName = jsonMap['file_name']?.toString() ?? '',
        url = jsonMap['original_url']?.toString() ??
            jsonMap['original_url']?.toString() ??
            '',
        thumb = jsonMap['thumb']?.toString() ?? '',
        icon = jsonMap['icon']?.toString() ?? '',
        size = jsonMap['size']?.toString() ?? '',
        mimeType = jsonMap['mime_type']?.toString() ?? '';

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["file_name"] = fileName;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    map["mime_type"] = mimeType;
    return map;
  }
}
