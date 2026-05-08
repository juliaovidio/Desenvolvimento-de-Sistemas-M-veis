import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'src/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🗺️ Configurar Google Maps para Android
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  // 🔐 Inicializar Supabase
  await Supabase.initialize(
    url: 'https://bogymaxfgwvjbozwnybd.supabase.co',
    anonKey: 'sb_publishable_e3zyGGtObJiIG9v3-0RVFQ_LQXXu9ae',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 🔥 COMEÇA NO LOGIN
      home: LoginPage(),
    );
  }
}