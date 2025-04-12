// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/services/auth_service.dart';
import 'package:connect_aac/screens/login_screen.dart'; // To navigate after logout
import 'package:connect_aac/screens/category_screen.dart';
import 'package:connect_aac/screens/settings_screen.dart';
import 'package:connect_aac/screens/custom_vocabulary_screen.dart';
// Import other screens if you add them to the BottomNavigationBar
// import 'package:connect_aac/screens/favorites_screen.dart';
// import 'package:connect_aac/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar

  // Define the screens for the BottomNavigationBar
  // Ensure these screens exist and are imported
  static final List<Widget> _widgetOptions = <Widget>[
    const CategoryScreen(), // Index 0
    // Add other main screens here corresponding to BottomNavigationBar items
    // const FavoritesScreen(), // Example: Index 1
    // const ChatScreen(), // Example: Index 2
    const CustomVocabularyScreen(), // Index 1 (Adjust index based on items)
    const SettingsScreen(), // Index 2 (Adjust index based on items)
  ];

  // Define the BottomNavigationBar items
  static const List<BottomNavigationBarItem> _navBarItems = [
     BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(Icons.category), // Optional: different icon when active
      label: '카테고리',
    ),
    // Add items corresponding to _widgetOptions
    // BottomNavigationBarItem(
    //   icon: Icon(Icons.favorite_border),
    //   activeIcon: Icon(Icons.favorite),
    //   label: '즐겨찾기',
    // ),
    // BottomNavigationBarItem(
    //   icon: Icon(Icons.chat_bubble_outline),
    //   activeIcon: Icon(Icons.chat_bubble),
    //   label: '채팅',
    // ),
     BottomNavigationBarItem(
      icon: Icon(Icons.add_circle_outline),
      activeIcon: Icon(Icons.add_circle),
      label: '단어 추가',
    ),
     BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: '설정',
    ),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Future<void> _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    // Show confirmation dialog before logging out (good practice)
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false), // Cancel
                    child: const Text('취소'),
                ),
                TextButton(
                    onPressed: () => Navigator.pop(context, true), // Confirm
                    child: const Text('확인'),
                 ),
            ],
         ),
     );

     if (confirmed == true) {
        await authService.logout();
        // Navigation should be handled by the listener on AuthService or SplashScreen
        // But add explicit navigation just in case
         if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false, // Remove all routes below
            );
         }
     }
  }

  @override
  Widget build(BuildContext context) {
     // Determine the title based on the selected screen index
     String appBarTitle;
     switch (_selectedIndex) {
        case 0:
            appBarTitle = '카테고리';
            break;
        case 1:
            appBarTitle = '커스텀 단어 추가';
             break;
        case 2:
            appBarTitle = '설정';
             break;
        // Add cases for other screens
        default:
            appBarTitle = 'Connect AAC';
     }


     // Using a standard Scaffold, integrate with AppScaffold if preferred
     return Scaffold(
       appBar: AppBar(
         title: Text(appBarTitle),
         actions: [
           // Show logout button only on certain screens or always
           // if (_selectedIndex == 2) // Example: Only on Settings screen
             IconButton(
               icon: const Icon(Icons.logout),
               onPressed: () => _logout(context),
               tooltip: '로그아웃',
             ),
         ],
       ),
       body: Center(
          // Display the selected screen widget
          child: _widgetOptions.elementAt(_selectedIndex),
       ),
        bottomNavigationBar: BottomNavigationBar(
          items: _navBarItems,
          currentIndex: _selectedIndex,
          // Use theme colors
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade600,
          onTap: _onItemTapped,
          // type: BottomNavigationBarType.shifting, // Or shifting for animation effect
          type: BottomNavigationBarType.fixed, // Ensures labels are always visible
          showUnselectedLabels: true, // Optional: show labels for unselected items
       ),
     );
  }
}
