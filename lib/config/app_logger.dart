import 'package:logging/logging.dart' as logging;
import 'package:sentry_flutter/sentry_flutter.dart';

/// Singleton que escribe SIEMPRE en consola y, además,
/// envía a Sentry si Sentry está inicializado.
class AppLogger {
  AppLogger._();

  static final logging.Logger _local = logging.Logger('App');

  /* ----------  init: salida local  ---------- */
  static void initConsole() {
    logging.Logger.root.level = logging.Level.ALL;
    logging.Logger.root.onRecord.listen((rec) {
      // ignore: avoid_print
      print(
        '${rec.level.name.padRight(7)} │ ${rec.loggerName} │ ${rec.message}',
      );
    });
  }

  /* ----------  métodos públicos  ---------- */
  static void d(String msg, {Object? error, StackTrace? stackTrace}) {
    _local.fine(msg, error, stackTrace);
    _sendToSentry(SentryLevel.debug, msg, error: error, stackTrace: stackTrace);
  }

  static void i(String msg, {Object? error, StackTrace? stackTrace}) {
    _local.info(msg, error, stackTrace);
    _sendToSentry(SentryLevel.info, msg, error: error, stackTrace: stackTrace);
  }

  static void w(String msg, {Object? error, StackTrace? stackTrace}) {
    _local.warning(msg, error, stackTrace);
    _sendToSentry(
      SentryLevel.warning,
      msg,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void e(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    _local.severe(msg, error, stackTrace);
    _sendToSentry(
      fatal ? SentryLevel.fatal : SentryLevel.error,
      msg,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /* ----------  envío opcional a Sentry  ---------- */
  static void _sendToSentry(
    SentryLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Solo enviamos si Sentry está inicializado
    if (!Sentry.isEnabled) return;

    // Si hay error, usar captureException
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({'message': message, 'level': level.name}),
      );
    } else {
      // Si no hay error, usar captureMessage con breadcrumb
      Sentry.addBreadcrumb(
        Breadcrumb(message: message, level: level, timestamp: DateTime.now()),
      );

      // Para errores y warnings, también enviar como mensaje
      if (level == SentryLevel.error ||
          level == SentryLevel.fatal ||
          level == SentryLevel.warning) {
        Sentry.captureMessage(message, level: level);
      }
    }
  }
}
