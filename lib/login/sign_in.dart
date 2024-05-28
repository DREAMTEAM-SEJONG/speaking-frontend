import 'package:flutter/material.dart';
import 'package:mal_hae_bol_le/login/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mal_hae_bol_le/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _emailInputText = TextEditingController();
  var _passInputText = TextEditingController();

  void dispose() {
    _emailInputText.dispose();
    _passInputText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            color: Colors.grey.shade800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 0, left: 20, bottom: 20),
                        child: Text(
                          'E-mail',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: TextField(
                          key: ValueKey(3),
                          controller: _emailInputText,
                          decoration: InputDecoration(
                            hintText: 'E-mail',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 50, left: 20, bottom: 20),
                        child: Text(
                          'Password',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: TextField(
                          key: ValueKey(4),
                          controller: _passInputText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                );
                              },
                              child: Text(
                                'Sign-up',
                                style: TextStyle(fontSize: 20),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.grey.shade900),
                        padding: MaterialStateProperty.all(EdgeInsets.only(
                            left: 150, right: 150, top: 10, bottom: 10)),
                      ),
                      onPressed: () async {
                        // 이메일, 비번 중 하나라도 비워있으면 패스
                        if (_emailInputText.text.isEmpty ||
                            _passInputText.text.isEmpty) return;

                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailInputText.text.toLowerCase().trim(),
                            password: _passInputText.text.trim(),
                          );
                          print('success login');

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        } on FirebaseAuthException catch (e) {
                          print('an error occured $e');
                        }
                      },
                      child: Text(
                        'Login',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
