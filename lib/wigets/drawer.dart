import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/theme_provider.dart';

class ReusableDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const ReusableDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Smart Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your one-stop shop',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            index: 0,
            currentIndex: currentIndex,
            onTap: () => onItemSelected(0),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.search,
            title: 'Search',
            index: 1,
            currentIndex: currentIndex,
            onTap: () => onItemSelected(1),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.shopping_cart,
            title: 'Cart',
            index: 2,
            currentIndex: currentIndex,
            onTap: () => onItemSelected(2),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'Profile',
            index: 3,
            currentIndex: currentIndex,
            onTap: () => onItemSelected(3),
          ),
          const Divider(),
          _buildDrawerItem(
            context: context,
            icon: Icons.favorite,
            title: 'Favorites',
            index: -1, 
            currentIndex: currentIndex,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            index: -1, 
            currentIndex: currentIndex,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              themeProvider.getIsDarkTheme ? Icons.light_mode : Icons.dark_mode,
            ),
            title: Text(
              themeProvider.getIsDarkTheme ? "Light Mode" : "Dark Mode",
            ),
            trailing: Switch(
              value: themeProvider.getIsDarkTheme,
              onChanged: (value) {
                themeProvider.setDarkTheme(value);
              },
            ),
            onTap: () {
              themeProvider.setDarkTheme(!themeProvider.getIsDarkTheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index && index != -1;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}