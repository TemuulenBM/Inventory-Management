import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:retail_control_platform/core/routing/app_router.dart';
import 'package:retail_control_platform/core/theme/app_theme.dart';
import 'package:retail_control_platform/l10n/app_localizations.dart';
// import 'package:retail_control_platform/core/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

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

  // Sentry — Production алдаа мониторинг
  // DSN байхгүй бол (development) Sentry-гүйгээр ажиллана
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = dotenv.env['ENVIRONMENT'] ?? 'development';
        // Performance tracking — 20% sample rate (production ачаалал бууруулах)
        options.tracesSampleRate = 0.2;
        // Хэрэглэгчийн хувийн мэдээлэл илгээхгүй (GDPR)
        options.sendDefaultPii = false;
      },
      // SentryFlutter.init автоматаар FlutterError.onError,
      // PlatformDispatcher.onError, runZonedGuarded тохируулна
      appRunner: () => runApp(const ProviderScope(child: MyApp())),
    );
  } else {
    runApp(const ProviderScope(child: MyApp()));
  }
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

