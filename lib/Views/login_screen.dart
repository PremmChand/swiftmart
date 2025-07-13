import 'package:flutter/material.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Screen/admin_home_screen.dart';
import 'package:swiftmart/Views/Role_based_login/User/app_main_screen.dart';
import 'package:swiftmart/Views/signup_screen.dart';
import 'package:swiftmart/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordHidden = true;
  final AuthService _authService = AuthService();

  void login() async {
    setState(() {
      isLoading = true;
    });

    String? result = await _authService.login(
      email: emailController.text,
      password: passwordController.text,
    );
    setState(() {
      isLoading = false;
    });

    if (result == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHomeScreen()),
      );
    } else if (result == "User") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppMainScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup Failed $result")));
    }
  }
  
@override
void dispose() {
  emailController.dispose();
  passwordController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset("assets/user_login.jpeg"),
              SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: isPasswordHidden,
              ),
              SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:login,
                      child: Text('Login'),
                    ),
                  ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "Signup here",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
