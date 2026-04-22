import 'dart:typed_data';
import 'package:flutter/services.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, Uint8List> _cache = {};
  final int _maxCacheSize = 20; // Keep max 20 assets in memory

  // Pre-load frequently used assets
  Future<void> preloadFrequentAssets() async {
    final frequentAssets = [
      'assets/letters/space.png',
      'assets/ISL_Gifs/hello.gif',
      'assets/ISL_Gifs/good.gif',
      'assets/ISL_Gifs/morning.gif',
      'assets/ISL_Gifs/you.gif',
    ];

    for (final asset in frequentAssets) {
      try {
        await _loadAsset(asset);
      } catch (e) {
        print('Error preloading $asset: $e');
      }
    }
  }

  Future<Uint8List?> _loadAsset(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path];
    }

    try {
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();

      // Add to cache
      _cache[path] = bytes;

      // Manage cache size
      if (_cache.length > _maxCacheSize) {
        final firstKey = _cache.keys.first;
        _cache.remove(firstKey);
      }

      return bytes;
    } catch (e) {
      print('Error loading asset $path: $e');
      return null;
    }
  }

  Uint8List? getCachedAsset(String path) {
    return _cache[path];
  }

  void clearCache() {
    _cache.clear();
  }

  void removeAsset(String path) {
    _cache.remove(path);
  }

  int getCacheSize() {
    return _cache.length;
  }

  // Pre-load next signs in sequence
  Future<void> preloadNextSigns(List<String> words) async {
    for (final word in words.take(3)) { // Preload next 3
      final path = 'assets/ISL_Gifs/$word.gif';
      try {
        await _loadAsset(path);
      } catch (e) {
        // Try letter path if word gif doesn't exist
        final letterPath = 'assets/letters/${word[0]}.png';
        try {
          await _loadAsset(letterPath);
        } catch (e) {
          print('Error preloading sign for $word: $e');
        }
      }
    }
  }

  // Memory optimization - compress and optimize
  void optimizeMemory() {
    if (_cache.length > _maxCacheSize ~/ 2) {
      // Remove least recently used items
      final keysToRemove = _cache.keys.take(_cache.length ~/ 2).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }
}

