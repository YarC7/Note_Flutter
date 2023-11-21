import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/screens/forgot_password.dart';
import 'package:note_app/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/constants/utility.dart';
import 'package:note_app/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String id = "login_screen";

  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  bool showSpinner = false;
  String email = '';
  String password = '';
  final _auth = FirebaseAuth.instance;

  bool isCheckedRememberMe = false;
  bool isVisible = true;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.black;
  }

  @override
  void initState() {
    super.initState();
    getRemember();
  }

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
          child : Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children : [
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
                  child : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
                    children: [
                      Image.asset('assets/notes.png', width: 100, height: 100,),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Center(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          child: Text(
                            'Hello There, Welcome Back',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                    TextField(
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.white,
                        // Color of the input text while typing
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                      decoration:
                      kEmailFieldDecoration.copyWith(hintText: 'Enter your email ',
                      suffixIcon: IconButton(onPressed:(){} , icon: const Icon(Icons.mail))),



                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      obscureText: isVisible,
                      style: TextStyle(
                        color: Colors.white, // Color of the input text while typing
                      ),
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: kPassFieldDecoration.copyWith(
                          hintText: 'Enter your password ',
                          suffixIcon: IconButton(
                              onPressed: (){
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: isVisible ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility))
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.resolveWith(getColor),
                              value: isCheckedRememberMe!,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedRememberMe = value!;
                                });
                              },
                          ),

                                SizedBox(width: 10.0),
                                Text("Remember Me",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                            SizedBox(width: 40.0),
                            Text.rich(
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'Forgot Password', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white , fontSize: 16),recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => ForgotPasswordScreen()))),
                                  )],
                              ),
                            ),

                              ]),
                    Container(
                      width: 50,
                      child: OutlinedButton(
                          child: const Text('Log in',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: 20)),
                          style: ButtonStyle(
                            backgroundColor:  MaterialStatePropertyAll<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),

                                    side: BorderSide(color: Colors.black)
                                )
                            ),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // Adjust the horizontal padding
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            if (email=='' && password == ''){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('please input email or password.')));;
                            }
                            //Login to existing account
                            try {
                              await _auth
                                  .signInWithEmailAndPassword(
                                  email: email, password: password)
                                  .then((value) {
                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeScreen()));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Successfully Login.')));
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
                                    content: Text('Log in  Failed. Due to ${e.message}'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Log in Failed. Due to $e'),
                                ),
                              );
                            }
                          }),

                      ),
                      const SizedBox(
                        height: 20.0,
                      )
                      ,Center(
                        child:
                            Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Or login with!!!', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)
                                      )],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),

                                Row(
                                  mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Tab(icon: Image.asset("assets/statics/facebook.png"),),
                                    Tab(icon: Image.asset("assets/statics/github.png"),),
                                    Tab(icon: Image.asset("assets/statics/google.png"),)
                                  ],
                                ),
                              ],
                            )


                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'New Here , Lets Sign Up Now!!! ', style: TextStyle(fontStyle: FontStyle.italic,color: Colors.white)),
                              TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => const RegistrationScreen()))),
                              )],
                          ),
                        ),
                      )
                  ],
                )
                ),
        ]),
      ),
      ),
    );
  }

  // actionRemeberMe(bool value) {
  //   isCheckedRememberMe = value;
  //   SharedPreferences.getInstance().then(
  //         (prefs) {
  //       prefs.setBool("remember_me", value);
  //       prefs.setString('email', email);
  //       prefs.setString('password', password);
  //     },
  //   );
  //   setState(() {
  //     isCheckedRememberMe = value;
  //   });
  // }
  Future<void> getRemember()
  async {

    final prefs = await SharedPreferences.getInstance();
    isCheckedRememberMe = prefs.getBool('remember')??false;
    if(isCheckedRememberMe){
      email= prefs.getString('email')??"";
      password= prefs.getString('password')??"";
    }
    setState(() {});
  }

  //checkbox işaretliyse veriyi değilse boş string kaydediyoruz. Bunu login olabiliyorsa tetikliyoruz. sayfa değişmeden önce.
  Future<void> setRemember()
  async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', isCheckedRememberMe ? email : "");
    await prefs.setString('password', isCheckedRememberMe ? password : "");
    await prefs.setBool('remember', isCheckedRememberMe );
  }
}