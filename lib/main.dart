import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Screen/admin_home_screen.dart';
import 'package:swiftmart/Views/Role_based_login/User/app_main_screen.dart';
import 'package:swiftmart/Views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: AuthStateHandler(),
      ),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  User? _currentUser;
  String? _userRole;

  @override
  void initState() {
    _initializeAuthState();
    super.initState();
  }

  void _initializeAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();
        if (!mounted) return;
        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc['role'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const LoginScreen();
    }
    if (_userRole == null) {
      //show a loading scaffold
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _userRole == "Admin"
        ? const AdminHomeScreen()
        : const AppMainScreen();
  }
}
