// welcome_screen.dart
import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'forgot_password_screen.dart';  // Import ForgotPasswordScreen

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late bool changeColor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
                    'Note App',
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              Container(
                width: 150,
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: changeColor
                        ? MaterialStateProperty.all<Color>(Colors.grey)
                        : MaterialStateProperty.all<Color>(Colors.white),
                    iconColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onHover: (hovered) {
                    setState(() {
                      changeColor = hovered;
                    });
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.login_outlined),
                      SizedBox(width: 10,),
                      Text(
                        'Sign In',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: 150,
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: changeColor
                        ? MaterialStateProperty.all<Color>(Colors.grey)
                        : MaterialStateProperty.all<Color>(Colors.white),
                    iconColor: MaterialStateProperty.all<Color>(Colors.black),
                    alignment: Alignment.center,
                  ),
                  onHover: (hovered) {
                    setState(() {
                      changeColor = hovered;
                    });
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.app_registration_sharp),
                      SizedBox(width: 10,),
                      Text(
                        'Sign Up',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: 150,
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: changeColor
                        ? MaterialStateProperty.all<Color>(Colors.grey)
                        : MaterialStateProperty.all<Color>(Colors.white),
                    iconColor: MaterialStateProperty.all<Color>(Colors.black),
                    alignment: Alignment.center,
                  ),
                  onHover: (hovered) {
                    setState(() {
                      changeColor = hovered;
                    });
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock),
                      SizedBox(width: 10,),
                      Text(
                        'Forgot Password',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
