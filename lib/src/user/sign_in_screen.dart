import 'package:flutter/material.dart';
import 'package:kw_inventory/src/firebase/firebase_service.dart';
import 'package:kw_inventory/src/sample_feature/sample_item_list_view.dart';
import 'package:kw_inventory/src/utils/helper_functions.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../screens/home_screen.dart';
import '../settings/settings_controller.dart';

class SignInScreen extends StatefulWidget {
  final SettingsController settingsController;

  const SignInScreen({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  static const routeName = '/sign_in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _signInButtonController =
    RoundedLoadingButtonController();
  final RoundedLoadingButtonController _signUpButtonController =
  RoundedLoadingButtonController();

  String messageLabel = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 9),
              const Text(
                'Inventory Manager',
                style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 20),
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 3.5
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'your@email.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15))
                            )
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (messageLabel.isNotEmpty) Align(
                        alignment: Alignment.center,
                        child: Text(
                          messageLabel,
                          style: TextStyle(
                              color: Colors.red.shade600
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      RoundedLoadingButton(
                        onPressed: () async {
                          if (_emailController.text != "") {
                            if (_passwordController.text != "") {
                              FocusManager.instance.primaryFocus?.unfocus();
                              final retVal =
                              await firebaseService.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text
                              );

                              if (retVal == "Success") {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                          settingsController: widget.settingsController
                                        ),
                                    )
                                );
                              } else {
                                _signInButtonController.stop();
                                updateMessageLabel(retVal!);
                              }
                            } else {
                              _signInButtonController.stop();
                              updateMessageLabel('Password is required');
                            }
                          } else {
                            _signInButtonController.stop();
                            updateMessageLabel('Email is required');
                          }
                        },
                        controller: _signInButtonController,
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                        color: Colors.blue.shade500,
                        borderRadius: 15,
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      )
    );
  }

  void updateMessageLabel(String newMessage) {
    setState(() {
      messageLabel = newMessage;
    });
  }

}
