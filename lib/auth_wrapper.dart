import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:potholedetect/explore.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return const LoginPage();
    } else {
      return const ExplorePage();
    }
  }
}
