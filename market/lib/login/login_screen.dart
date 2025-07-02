import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:market/login/provider/login_provider.dart';
import 'package:market/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credential);
      // userCredential = credential;
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print(e.toString());
      } else if (e.code == "wrong-password") {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                Text(
                  "_market",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Colors.black87,
                    letterSpacing: -1,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "간편하게 시작하세요",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 48),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.black87,
                              width: 1,
                            ),
                          ),
                          hintText: "이메일",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "이메일을 입력해주세요.";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.black87,
                              width: 1,
                            ),
                          ),
                          hintText: "비밀번호",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        obscureText: true,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "비밀번호를 입력해주세요.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final result = await signIn(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (result == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("로그인 실패"),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: EdgeInsets.all(16)
                                  ),
                                );
                              }
                              return;
                            }

                            ref.watch(userCredentialProvider.notifier).state =
                                result;

                            if (context.mounted) {
                              context.go("/");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "로그인",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.push("/sign_up"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black87, width: 1),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: Text(
                      "회원가입",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey.shade300),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "또는",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey.shade300),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return OutlinedButton(
                        onPressed: () async {
                          final result = await signInWithGoogle();

                          if (result == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("구글 로그인 실패"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.all(16)
                                ),
                              );
                            }
                            return;
                          }

                          ref.watch(userCredentialProvider.notifier).state = result;

                          if (context.mounted) {
                            context.go("/");
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Image.asset("assets/google.png", width: 20, height: 20),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Google로 로그인",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
