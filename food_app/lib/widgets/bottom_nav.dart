import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/cart/cart_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _index = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      elevation: 10,
      selectedItemColor: const Color(0xFFEF2A39),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (i) {
        setState(() => _index = i);
        Navigator.push(context, MaterialPageRoute(builder: (_) => pages[i]));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: "Cart",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chat",
        ),
      ],
    );
  }
}
