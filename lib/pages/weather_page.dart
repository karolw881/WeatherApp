import 'package:flutter/material.dart';
import '../models/city_weather.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  List<CityWeather> weatherData = [];
  bool isLoading = true;
  int currentIndex = 0; // Do sledzenia indexu obecnego miasta

  @override
  void initState() {
    super.initState();
    loadWeatherData(); // laduj dane
  }

  Future<void> loadWeatherData() async {
    try {
      final data = await _weatherService.fetchWeatherData();
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading weather data: $e');

      // laduj dane jesli polaczenie internetowe zawiedzie
      try {
        final localData = await _weatherService.fetchWeatherData();
        setState(() {
          weatherData = localData;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              loadWeatherData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherData.isEmpty
          ? const Center(child: Text('No weather data available'))
          : Column(
        children: [
          Expanded(
            child: WeatherCard(weather: weatherData[currentIndex]),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex--;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                const SizedBox(width: 16),
                if (currentIndex < weatherData.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex++;
                      });
                    },
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
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
            // Create a new widget for "Region"
            RegionWidget(region: weather.region), // Use the RegionWidget
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

// New widget for "Region"
class RegionWidget extends StatelessWidget {
  final String region;

  const RegionWidget({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Add padding to the bottom
      child: Text('Region: $region'),
    );
  }
}