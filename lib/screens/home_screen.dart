import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/theme_provider.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/wigets/apptextname.dart';
import 'package:smartshop/wigets/drawer.dart';
import 'package:smartshop/wigets/titletext.dart';

class HomeScreen extends StatefulWidget {
  static const routName = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  int _currentIndex = 0; 

  _increment() {
    setState(() {
      _counter++;
    });
  }

  void _onDrawerItemSelected(int index) {
    if (index == _currentIndex) {
      Navigator.pop(context);
      return;
    }

    switch (index) {
      case 0: // Home
        Navigator.pop(context);
        break;
      case 1: // Search
        Navigator.pop(context);
        Navigator.pushNamed(context, '/search');
        break;
      case 2: // Cart
        Navigator.pop(context);
        Navigator.pushNamed(context, '/cart');
        break;
      case 3: // Profile
        Navigator.pop(context);
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const  Apptextname(fontSize: 34.5),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: ReusableDrawer(
        currentIndex: _currentIndex,
        onItemSelected: _onDrawerItemSelected,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetsManager.banner1),
            // ElevatedButton(
            //   onPressed: _increment, 
            //   child: const Text("Shop Now")
            // ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                themeProvider.getIsDarkTheme ? "Dark Theme" : "Light theme",
              ),
              value: themeProvider.getIsDarkTheme,
              onChanged: (value) {
                themeProvider.setDarkTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}