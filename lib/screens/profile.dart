import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {


  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen> {

  final _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'), // Replace with your image path
              fit: BoxFit.cover, // You can adjust the fit as needed
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                IconButton(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(.8),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(
                          Icons.login_outlined,
                          color: Colors.white,
                        ),
                      ),
                ),],
              ),
                Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    child: Text(
                      'Profile',
                    ),
                  ),
                ),
              SizedBox(
                height: 50,
              ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(.8),
                      borderRadius: BorderRadius.circular(10)),
                    width: 200, // Set a specific width
                    height: 200,
                  child: Image.asset('assets/user.png',width: 100, height: 100), // <-- SEE HERE,
                )
              ]
            ),
          ),
        )
    );
  }

}