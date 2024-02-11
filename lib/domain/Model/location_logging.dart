class LocationLogging {
  final String orderID;
  final double latitude;
  final double longitude;
  final int timestamp;

  LocationLogging(this.orderID, this.latitude, this.longitude, this.timestamp);

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }
}
