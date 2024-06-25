import 'package:eid_moo/features/auth/login_screen.dart';
import 'package:eid_moo/features/auth/signup_screen.dart';
import 'package:eid_moo/features/auth/welcome_screen.dart';
import 'package:eid_moo/features/general/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'eid_moo',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EidMoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: EMAuthInstance.checkAuth()
      //     ? const LoginScreen()
      //     : const SignUpScreen(),
      home: FutureBuilder(
        future: storage.readAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {

            final secureStorage = snapshot.data as Map<String, String>;

            if (secureStorage['refreshToken'] != null) {
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          }

          return const SignUpScreen();

        },
      ),
    );
  }
}
