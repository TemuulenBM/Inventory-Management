import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retail_control_platform/core/routing/app_router.dart';
import 'package:retail_control_platform/core/theme/app_theme.dart';
import 'package:retail_control_platform/l10n/app_localizations.dart';
// import 'package:retail_control_platform/core/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Uncomment ба .env файлын SUPABASE_URL, SUPABASE_ANON_KEY оруулах
  // await SupabaseClientManager.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.lightSystemUiOverlayStyle);

  // Set preferred orientations (portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App metadata
      title: 'Retail Control Platform',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Follows system theme

      // Router
      routerConfig: appRouter,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('mn', ''), // Mongolian
      ],
      locale: const Locale('mn', ''), // Default Mongolian

      // Builder for system UI overlay updates on theme change
      builder: (context, child) {
        // Update system UI overlay based on theme brightness
        final brightness = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(
          brightness == Brightness.dark
              ? AppTheme.darkSystemUiOverlayStyle
              : AppTheme.lightSystemUiOverlayStyle,
        );

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

