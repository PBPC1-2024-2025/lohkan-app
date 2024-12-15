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
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white, 
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.grey.shade100, 
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white, 
            surfaceTintColor: Colors.white,
          ),
          cardTheme: const CardTheme(
            color: Colors.white, 
            surfaceTintColor: Colors.white,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFF550000), 
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: CircleBorder(), // Pastikan bentuk bulat
          ),
        ),
        home: const LoginPage(), 
      )

    );
  }
}