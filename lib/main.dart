import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_social/Feature/feed/feed.dart';
import 'package:github_social/Feature/github%20frofile/github_profile_screeen.dart';
import 'package:github_social/Feature/landing/landing_screen.dart';
import 'package:github_social/firebase_options.dart';
import 'package:github_social/github_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load token from storage
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('githubAccessToken');

  runApp(MyApp(accessToken: accessToken));
}

class MyApp extends StatelessWidget {
  final String? accessToken;

  const MyApp({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Login Error: ${snapshot.error}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && accessToken != null) {
              return LandingScreenView(accessToken: accessToken!);
            } else {
              return const GithubLogin();
            }
          },
        ),
      ),
    );
  }
}
