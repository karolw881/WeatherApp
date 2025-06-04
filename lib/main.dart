import 'package:flutter/material.dart';
import '../models/city_weather.dart';
import '../services/weather_service.dart';

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
        primarySwatch: Colors.blue,
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
  final WeatherService _weatherService = WeatherService();
  List<CityWeather> weatherData = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadWeatherData();
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
            RegionWidget(region: weather.region),
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
            // Expandable Forecast Widget
            ForecastExpandableWidget(
              forecast: weather.forecast,
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

// Widget for "Region"
class RegionWidget extends StatelessWidget {
  final String region;

  const RegionWidget({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text('Region: $region'),
    );
  }
}

// Expandable widget that shows forecast preview and expands to show details
class ForecastExpandableWidget extends StatefulWidget {
  final List<Forecast> forecast;


  const ForecastExpandableWidget({
    super.key,
    required this.forecast,
  });

  @override
  State<ForecastExpandableWidget> createState() => _ForecastExpandableWidgetState();
}

class _ForecastExpandableWidgetState extends State<ForecastExpandableWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });

    if (isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          // Header - always visible
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Forecast:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Preview - always visible
                  ForecastPreviewWidget(forecast: widget.forecast),
                ],
              ),
            ),
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    'Detailed Hourly Forecast',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Full forecast list
                  ...widget.forecast.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.hour}h',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${item.hour}:00',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${item.temp}°C',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.thermostat,
                              size: 16,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Preview widget showing first few forecast items
class ForecastPreviewWidget extends StatelessWidget {
  final List<Forecast> forecast;

  const ForecastPreviewWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Show only first 4 items in preview
    final previewItems = forecast.take(4).toList();

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: previewItems.map((forecastItem) {
          return Column(
            children: [
              Text('${forecastItem.hour}:00'),
              const SizedBox(height: 4),
              Text(
                '${forecastItem.temp}°C',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}