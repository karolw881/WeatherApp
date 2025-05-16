// file: lib/services/cache_manager.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class WeatherCacheManager {
  static const key = 'weatherCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}