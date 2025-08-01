import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:github_social/Feature/landing/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GithubLogin extends StatelessWidget {
  const GithubLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              UserCredential credential = await signInWithGithub();
              // Get the GitHub access token
              final githubCredential = credential.credential;
              final accessToken = githubCredential?.accessToken;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('githubAccessToken', accessToken!);
              // print('Access Token: $accessToken'); // Debug print

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LandingScreenView(accessToken: accessToken),
                  ),
                );
              }
            } catch (e) {
              // print('GitHub login error: $e');
              // Show error dialog
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Login Error'),
                    content: Text('Failed to login with GitHub: $e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          child: Text("GitHub Login"),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGithub() async {
    GithubAuthProvider authProvider = GithubAuthProvider();
    // Add required scopes for accessing repositories and user data
    authProvider.addScope('repo');
    authProvider.addScope('user');
    authProvider.addScope('notifications');
    authProvider.addScope('read:org');

    return await FirebaseAuth.instance.signInWithProvider(authProvider);
  }
}
