import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/city_weather.dart';
import 'cache_manager.dart';

class WeatherService {
  static const String apiUrl = 'https://startling-sprite-835369.netlify.app/pogoda.json';

  Future<List<CityWeather>> fetchWeatherData() async {
    try {
      // Sprobuj zaladowac dane z cache na poczatku
      final fileInfo = await WeatherCacheManager.instance.getFileFromCache(apiUrl);

      if (fileInfo != null && !fileInfo.file.path.isEmpty) {
        // Jesli istnieja lub nie wygasly
        final fileContents = await fileInfo.file.readAsString();
        final List<dynamic> jsonData = json.decode(fileContents);
        return jsonData
            .map((data) => CityWeather.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      // Jesli z pamieci podrecznej nie zaladuje, obierz z internetu
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // zapisz do pamieci podrecznej
        await WeatherCacheManager.instance.putFile(
          apiUrl,
          response.bodyBytes,
          fileExtension: 'json',
        );

        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((data) => CityWeather.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server returned error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      return [];
    }
  }

}