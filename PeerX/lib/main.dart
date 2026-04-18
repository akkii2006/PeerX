import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/identity/identity_service.dart';
import 'core/relay/relay_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/push_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);


  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));

  // Must await — app screens depend on deviceId being set
  await IdentityService().init();

  // Init local notifications
  await NotificationService().init();

  // Request Android notification permission
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }

  // Fire and forget — non-blocking, app works fine without push
  PushService().init();

  // Connect to relay
  try {
    await RelayService().connect();
  } catch (_) {}


  final observer = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(observer);

  runApp(const PeerXApp());
}

class PeerXApp extends StatelessWidget {
  const PeerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'PeerX',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.dark(),
      home:                       const HomeScreen(),
    );
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  static bool isInForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isInForeground = state == AppLifecycleState.resumed;
  }
}