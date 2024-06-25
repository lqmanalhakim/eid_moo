import 'package:eid_moo/features/auth/signup_screen.dart';
import 'package:eid_moo/features/general/home_screen.dart';
import 'package:eid_moo/shared/components/em_button.dart';
import 'package:eid_moo/shared/components/em_text_field.dart';
import 'package:eid_moo/shared/utils/firebase/em_auth_instance.dart';
import 'package:eid_moo/shared/utils/theme/em_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ionicons/ionicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  AuthResponse? authResponse;

  final loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  Future<void> _signIn() async {
    if (loginFormKey.currentState!.validate()) {
      authResponse = await EMAuthInstance.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(authResponse);

      if (authResponse?.status ?? false) {
        print(authResponse?.userCredential?.user?.email);

        const storage = FlutterSecureStorage();

        final userItem = authResponse?.userCredential;

        Future.wait([
          storage.write(
            key: 'uid',
            value: userItem?.user?.uid ?? '',
          ),
          storage.write(
            key: 'email',
            value: userItem?.user?.email ?? '',
          ),
          storage.write(
            key: 'displayName',
            value: userItem?.user?.displayName ?? '',
          ),
          storage.write(
            key: 'photoURL',
            value: userItem?.user?.photoURL ?? '',
          ),
          storage.write(
            key: 'refreshToken',
            value: userItem?.user?.refreshToken ?? '',
          ),
        ]);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authResponse?.message ?? 'An error occurred'),
            ),
          );
        }
      }
    }

    loginFormKey.currentState!.reset();

    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        emailFocusNode.unfocus();
        passwordFocusNode.unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Form(
                key: loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/eidmoo_logo.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    EMTextField(
                      prefixIcon: const Icon(Ionicons.mail_outline),
                      focusNode: emailFocusNode,
                      controller: _emailController,
                      hintText: 'Email',
                      labelText: 'Email',
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    EMTextField(
                      prefixIcon: const Icon(Ionicons.lock_closed_outline),
                      focusNode: passwordFocusNode,
                      controller: _passwordController,
                      hintText: 'Password',
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: EMButton(
                        isLoading: isLoading,
                        backgroundColor: EidMooTheme.primaryVariant,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await _signIn();

                          print('Is loading: $isLoading');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: EidMooTheme.primaryVariant,
                          decoration: TextDecoration.underline,
                          decorationColor: EidMooTheme.primaryVariant,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Use Social Login',
                              style: TextStyle(
                                color: EidMooTheme.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              authResponse =
                                  await EMAuthInstance.signInWithGoogle();

                              if (authResponse?.status ?? false) {
                                print(
                                    authResponse?.userCredential?.user?.email);
                              }
                            },
                            icon: const Icon(
                              Ionicons.logo_google,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
