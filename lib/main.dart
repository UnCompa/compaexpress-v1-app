import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:compaexpress/config/aws_config.dart';
import 'package:compaexpress/config/theme_config.dart';
import 'package:compaexpress/page/auth/auth_check_screen.dart';
import 'package:compaexpress/providers/theme_provider.dart';
import 'package:compaexpress/utils/fecha_ecuador.dart';
import 'package:compaexpress/widget/loading_overlay.dart';
import 'package:compaexpress/widget/windows_wrapped_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import './routes/routes.dart';
import 'models/ModelProvider.dart';

bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FechaEcuador.inicializarZonaHoraria();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es_ES', null);

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DNS'];
      options.tracesSampleRate = 1.0; // Ajusta según necesites
      options.environment = 'production'; // o 'development'
    },
    appRunner: () {
      runApp(const ProviderScope(child: MyApp()));
      print(_isDesktop);
      if (_isDesktop) {
        doWhenWindowReady(() {
          const initialSize = Size(600, 450);
          appWindow
            ..minSize = initialSize
            ..alignment = Alignment.center
            ..maximizeOrRestore()
            ..show();
        });
      }
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final api = AmplifyAPI(
        options: APIPluginOptions(modelProvider: ModelProvider.instance),
      );
      final auth = AmplifyAuthCognito();
      final storage = AmplifyStorageS3();
      List<AmplifyPluginInterface> plugins = [auth, api, storage];
      await Amplify.addPlugins(plugins);
      await Amplify.configure(AwsConfig.prod);
      setState(() {
        _isAmplifyConfigured = true;
      });
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePrefs = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themePrefs.seedColor),
      darkTheme: AppTheme.darkTheme(themePrefs.seedColor),
      themeMode: themePrefs.themeMode,
      home: _isAmplifyConfigured
          ? WindowWrappedPage(child: const AuthCheckScreen())
          : const LoadingOverlay(caption: 'Iniciando aplicación'),
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        final builder = Routes.getRouteBuilder(routeName);

        if (builder != null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                WindowWrappedPage(title: routeName, child: builder(context)),
          );
        }

        return null; // Ruta no encontrada
      },
    );
  }
}
