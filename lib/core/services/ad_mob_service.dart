import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Cambiar en Produccion a: ca-app-pub-3600502933754206/4672211864
      return 'ca-app-pub-3600502933754206~8107758521';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3600502933754206~2503830635';
    }
    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (_) => print('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      print(' Ad failed to load: ${error.code} - ${error.message}');
      ad.dispose();
    },
  );
}
