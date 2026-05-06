import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/user_provider.dart';
import 'package:smartshop/wigets/titletext.dart';

class ProfileScreen extends StatefulWidget {
  static const routName = "/ProfileScreen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "assets/banner/dumbdraws-woman-7531315_640.png",
          fit: BoxFit.contain,
        ),
      ),
      body: Column(
        children: [
          TitlesTextWidget(label: user?.email ?? "Guest"),
          TitlesTextWidget(label: user?.username ?? ""),
          TitlesTextWidget(label: user?.role ?? ""),
        ],
      ),
    );
  }
}
