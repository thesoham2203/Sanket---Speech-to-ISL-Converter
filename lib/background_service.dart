import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background callback function (must be top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'preloadAssets':
        await _preloadAssets();
        break;
      case 'cleanCache':
        await _cleanCache();
        break;
      case 'syncHistory':
        await _syncHistory();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _preloadAssets() async {
  // Pre-load frequently used signs
  print('Background: Pre-loading assets');
  return Future.value();
}

Future<void> _cleanCache() async {
  // Clean old cache
  print('Background: Cleaning cache');
  final prefs = await SharedPreferences.getInstance();
  final lastClean = prefs.getInt('last_cache_clean') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  // Clean if last clean was more than 7 days ago
  if (now - lastClean > 7 * 24 * 60 * 60 * 1000) {
    await prefs.setInt('last_cache_clean', now);
  }
  return Future.value();
}

Future<void> _syncHistory() async {
  // Sync history to cloud (placeholder)
  print('Background: Syncing history');
  return Future.value();
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerPeriodicTasks() async {
    // Register periodic task to clean cache weekly
    await Workmanager().registerPeriodicTask(
      "cache-cleanup",
      "cleanCache",
      frequency: const Duration(days: 7),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }

  static Future<void> preloadNextSigns(List<String> nextWords) async {
    // Schedule one-time task to preload next signs
    await Workmanager().registerOneOffTask(
      "preload-${DateTime.now().millisecondsSinceEpoch}",
      "preloadAssets",
      inputData: {'words': nextWords},
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}

