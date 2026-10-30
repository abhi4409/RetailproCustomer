import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Supabase/Supabaseini.dart';
import 'firebase_options.dart';

import 'package:retailprocustomer/viewmodel/login_viewmodel.dart';
import 'package:retailprocustomer/viewmodel/home_viewmodel.dart';
import 'package:retailprocustomer/viewmodel/favorite_viewmodel.dart';
import 'package:retailprocustomer/viewmodel/order_viewmodel.dart';
import 'package:retailprocustomer/viewmodel/address_viewmodel.dart';
import 'package:retailprocustomer/viewmodel/profile_viewmodel.dart';

import 'package:retailprocustomer/view/login/Splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (_) {}
  }

  runApp(
    Proclass(),
  );
}

class Proclass extends StatelessWidget {
  Proclass({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewmodel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        home: Spla(),
      ),
    );
  }
}