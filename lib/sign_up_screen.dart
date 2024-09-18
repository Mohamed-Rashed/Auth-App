import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_graph_api/microsoft_graph_api.dart';
import 'package:microsoft_graph_api/models/user/user_model.dart';
import 'package:untitled5/helper.dart';
import 'package:untitled5/result_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {



  @override
  void initState() {
    super.initState();
  }
/// firebase
  // Future<UserCredential> signInWithMicrosoft() async {
  //   final microsoftProvider = MicrosoftAuthProvider();
  //   microsoftProvider.addScope('mail.read');
  //   if (kIsWeb) {
  //     var x = await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
  //     print("kkkkkk $x");
  //     return x;
  //   } else {
  //     var w = await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
  //     print("qqqqqqq $w");
  //     return w;
  //   }
  // }

/// SAML
  // void signInWithSAML() async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final SAMLAuthProvider provider = SAMLAuthProvider('saml.ejada-business.card');
  //   try {
  //     // Initiating sign-in with redirect
  //     final userCredential = await auth.signInWithProvider(provider);
  //     print("kkkkk ${userCredential.user}");
  //   } catch (e) {
  //     // Handle errors
  //     print('Error during sign-in: $e');
  //   }
  // }

  /// aad_OAuth
  void login(bool redirect) async {
    config.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
          (l) => showError(l.toString()),
          (r) async {
            String token = r.accessToken!;
            MSGraphAPI graphAPI = MSGraphAPI(token);

            User userInfo = await graphAPI.me.fetchUserInfo();
            print("kkkk${userInfo}");
            ImageProvider<Object>? userInfo2 = await graphAPI.me.fetchUserProfileImage('504x504');

        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultScreen(userInfo: userInfo,userImage: userInfo2)));
      },
    );
  }

Dio dio = Dio();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ejada Business Card"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                login(false);
              },
              child: Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString(),context);
  }
}
