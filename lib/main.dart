import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app_x/pages/lib/models/city_weather.dart';
import 'models/city_weather.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  List<CityWeather> weatherData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/weather.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        weatherData = jsonData.map((data) => CityWeather.fromJson(data)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherData.isEmpty
          ? const Center(child: Text('No weather data available'))
          : ListView.builder(
        itemCount: weatherData.length,
        itemBuilder: (context, index) {
          final weather = weatherData[index];
          return WeatherCard(weather: weather);
        },
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final CityWeather weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weather.city,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${weather.temperature}°C',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Region: ${weather.region}'),
            Text('Cloudiness: ${weather.cloudiness}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.air),
                Text(' Wind: ${weather.wind.speed} km/h ${weather.wind.direction}'),
              ],
            ),
            Row(
              children: [
                _getPrecipitationIcon(weather.precipitation.type),
                Text(' ${weather.precipitation.type}: ${weather.precipitation.amount} mm'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Forecast:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weather.forecast.length,
                itemBuilder: (context, index) {
                  final forecast = weather.forecast[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Text('${forecast.hour}:00'),
                        const SizedBox(height: 4),
                        Text('${forecast.temp}°C',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(weather.updated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Icon _getPrecipitationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'rain':
        return const Icon(Icons.water_drop);
      case 'snow':
        return const Icon(Icons.ac_unit);
      default:
        return const Icon(Icons.cloud);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}