// lib/services/sos_service.dart
// Platform-specific SOS service that works on both web and mobile

export 'sos_service_mobile.dart' if (dart.library.html) 'sos_service_web.dart';
