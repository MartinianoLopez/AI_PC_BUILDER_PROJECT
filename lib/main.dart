import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'package:flutter/foundation.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('✅ Firebase se conectó correctamente');
  } catch (e) {
    // ignore: avoid_print
    print('❌ Error al conectar Firebase: $e');
  }
  if (kIsWeb == false) {
    try {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['E5A4324AFBA36220A51FF1C8CC5B0F47']),
      );
      MobileAds.instance.initialize();
      print('✅ AdMob se conectó correctamente');
    } catch (e) {
      print("❌ Error al inicializar AdMob (Anuncios): $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ComponentsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.currentTheme,
      routerConfig: appRouter,
    );
  }
}
