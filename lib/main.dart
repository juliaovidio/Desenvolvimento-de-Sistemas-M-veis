import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bogymaxfgwvjbozwnybd.supabase.co',
    anonKey: 'sb_publishable_e3zyGGtObJiIG9v3-0RVFQ_LQXXu9ae',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 COMEÇA NO LOGIN
      home: LoginPage(),
    );
  }
}