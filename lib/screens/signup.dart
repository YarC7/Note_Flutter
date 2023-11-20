import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/constants/utility.dart';
import 'package:note_app/screens/home.dart';
class RegistrationScreen extends StatefulWidget {
  static String id = "Registration_screen";

  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  String email = '';
  String password = '';
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Replace with your image path
              fit: BoxFit.cover, // You can adjust the fit as needed
          ),
        ),
        child :Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(.8),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      )
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
                  children: [
                    Image.asset('assets/notes.png', width: 100, height: 100,),
                    const SizedBox(
                      height: 30.0,
                    ),
                    const Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        child: Text(
                          'Get Started !!!',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 48.0,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      style: TextStyle(
                        color: Colors.white, // Color of the input text while typing
                      ),
                      decoration:
                      kTextFieldDecoration.copyWith(hintText: 'Enter your email '),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      style: TextStyle(
                        color: Colors.white, // Color of the input text while typing
                      ),
                      decoration: kPassFieldDecoration.copyWith(
                          hintText: 'Enter your password '),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Container(
                      width: 50,
                      child: OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor:  MaterialStatePropertyAll<Color>(Colors.blue),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),

                                      side: BorderSide(color: Colors.black)
                                  )
                              )
                          ),
                          child: const Text('Register',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: 20)),
                          onPressed: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            if (email=='' && password == ''){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('please input email or password.')));;
                            }

                            //Create new Account
                            try {
                              await _auth
                                  .createUserWithEmailAndPassword(
                                  email: email, password: password)
                                  .then((value) {
                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeScreen()));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Successfully Register.')));;
                                });
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'invalid-email') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('The email address is badly formatted.'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Registration Failed. Due to ${e.message}'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registration Failed. Due to $e'),
                                ),
                              );
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Already A Member, ', style: TextStyle(fontStyle: FontStyle.italic,color: Colors.white)),
                            TextSpan(text: 'Sign In !!!', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => const RegistrationScreen()))),
                            )],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ],
            ),
          ),
      ),
    );
  }
}