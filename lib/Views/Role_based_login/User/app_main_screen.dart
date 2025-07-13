import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Activity/favorite_screen.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/user_profile.dart';
import 'package:swiftmart/Views/Role_based_login/User/app_home_screen.dart';
import 'package:swiftmart/Views/login_screen.dart';
import 'package:swiftmart/services/auth_service.dart';

AuthService _authService = AuthService();

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  final List pages = [
    const AppHomeScreen(),
    // const Scaffold(),
    const FavoriteScreen(),
    const UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {});
          selectedIndex = value;
        },
        elevation: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
          // BottomNavigationBarItem(
          //   icon: Icon(Iconsax.search_normal),
          //   label: "Search",
          // ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.heart),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
