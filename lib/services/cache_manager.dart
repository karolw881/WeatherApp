// file: lib/services/cache_manager.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class WeatherCacheManager {
  static const key = 'weatherCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key, // unikalny klucz
      stalePeriod: const Duration(hours: 1), // Swiezosc danych ustaiona na godzinke
      maxNrOfCacheObjects: 20, //Maksymalna ilosc
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}