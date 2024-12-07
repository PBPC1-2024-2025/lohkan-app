import 'package:flutter/material.dart';
import 'package:lohkan_app/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LohKan',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        home: const LoginPage(), // Memanggil HomePage dari file homepage.dart
      )
    );
  }
}
