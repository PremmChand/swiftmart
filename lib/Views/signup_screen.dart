import 'package:flutter/material.dart';
import 'package:swiftmart/Views/login_screen.dart';
import 'package:swiftmart/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String selectedRole = "User";
  bool isLoading = false;
  bool isPasswordHidden = true;
  final AuthService _authService = AuthService();

  void _signup() async {
    setState(() {
      isLoading = true;
    });
    String? result = await _authService.signup(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: selectedRole,
    );
    setState(() {
      isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Successful! Now Turn to Login")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup Failed $result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset("assets/signup.jpeg"),
                SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
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

                DropdownButtonFormField(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Role",
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ["Admin", "User"].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                ),

                SizedBox(height: 20),
                isLoading ? const Center(child: CircularProgressIndicator(),):
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Signup'),
                  ),
                ),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 18),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Login here",
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
      ),
    );
  }
}
