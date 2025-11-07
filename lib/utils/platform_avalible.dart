import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

bool get isMobile {
  if (kIsWeb) return false; // Web no es móvil
  return Platform.isAndroid || Platform.isIOS;
}

bool get isDesktop {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux || kIsWeb;
}
