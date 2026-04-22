import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sanket/speechToSign.dart';
import 'package:sanket/theme_manager.dart';
// import 'package:sanket/background_service.dart';  // Disabled - compatibility issue
import 'package:sanket/asset_manager.dart';
import 'package:sanket/autocomplete_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background services - DISABLED due to compatibility
  // await BackgroundService.initialize();
  // await BackgroundService.registerPeriodicTasks();

  // Pre-load assets
  await AssetManager().preloadFrequentAssets();

  // Initialize autocomplete
  AutocompleteService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Sanket',
            debugShowCheckedModeBanner: false,
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,
            home: AnimatedSplashScreen(
              splash: 'assets/logo/sanket_splash.png',
              duration: 1000,
              nextScreen: const SpeechScreen(),
              splashTransition: SplashTransition.fadeTransition,
              backgroundColor: themeManager.accentColor,
              pageTransitionType: PageTransitionType.fade,
            ),
          );
        },
      ),
    );
  }
}


