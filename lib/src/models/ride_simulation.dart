class RideSimulation {
  String price;
  double originalPrice;
  double originalDistance;
  String distance;

  RideSimulation({
    this.price = "",
    this.originalPrice = 0,
    this.originalDistance = 0,
    this.distance = "",
  });

  RideSimulation.fromJSON(Map<String, dynamic> jsonMap)
      : price = jsonMap['price']?.toString() ?? '',
        originalDistance = jsonMap['originalDistance'] != null
            ? double.parse(jsonMap['originalDistance'].toString())
            : 0.00,
        originalPrice = jsonMap['originalPrice'] != null
            ? double.parse(jsonMap['originalPrice'].toString())
            : 0.00,
        distance = jsonMap['distance']?.toString() ?? '';
}
