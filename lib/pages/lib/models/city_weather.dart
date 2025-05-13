class CityWeather {
  final String city;
  final int temperature;
  final String cloudiness;
  final Wind wind;
  final Precipitation precipitation;
  final String iconUrl;
  final Coordinates coordinates;
  final List<Forecast> forecast;
  final String region;
  final DateTime updated;

  CityWeather({
    required this.city,
    required this.temperature,
    required this.cloudiness,
    required this.wind,
    required this.precipitation,
    required this.iconUrl,

    required this.coordinates,
    required this.forecast,
    required this.region,
    required this.updated,
  });


  factory CityWeather.fromJson(Map<String, dynamic> json) => CityWeather(
    city: json['city'],
    temperature: json['temperature'],
    cloudiness: json['cloudiness'],
    wind: Wind.fromJson(json['wind']),
    precipitation: Precipitation.fromJson(json['precipitation']),
    iconUrl: json['iconUrl'],
    coordinates: Coordinates.fromJson(json['coordinates']),
    forecast: (json['forecast'] as List).map((e) => Forecast.fromJson(e)).toList(),
    region: json['region'],
    updated: DateTime.parse(json['updated']),
  );
}

class Wind {
  final int speed;
  final String direction;
  Wind({required this.speed, required this.direction});
  factory Wind.fromJson(Map<String, dynamic> json) =>
      Wind(speed: json['speed'], direction: json['direction']);
}

class Precipitation {
  final String type;
  final int amount;
  Precipitation({required this.type, required this.amount});
  factory Precipitation.fromJson(Map<String, dynamic> json) =>
      Precipitation(type: json['type'], amount: json['amount']);
}

class Coordinates {
  final double lat, lon;
  Coordinates({required this.lat, required this.lon});
  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      Coordinates(lat: json['lat'], lon: json['lon']);
}

class Forecast {
  final int hour, temp;
  Forecast({required this.hour, required this.temp});
  factory Forecast.fromJson(Map<String, dynamic> json) =>
      Forecast(hour: json['hour'], temp: json['temp']);
}
