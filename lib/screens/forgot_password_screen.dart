import 'package:flutter/material.dart';
import 'reset_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Đảm bảo bạn import Firebase Auth

class ForgotPasswordScreen extends StatelessWidget {
  static const String id = 'forgot_password_screen';

  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Đặt lại hình nền của bạn
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Forgot Password Screen',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(color: Colors.white), // Màu chữ cho label
                    ),
                    style: TextStyle(color: Colors.white), // Màu chữ cho input text
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      try {
                        // Gửi email đặt lại mật khẩu
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: emailController.text);

                        // Chuyển hướng đến trang ResetPasswordScreen
                        Navigator.pushNamed(
                          context,
                          ResetPasswordScreen.id,
                          arguments: emailController.text,
                        );
                      } on FirebaseAuthException catch (e) {
                        // Xử lý lỗi nếu có
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(e.message ?? 'An error occurred.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm kiểm tra email có đúng định dạng hay không
  bool isValidEmail(String email) {
    String emailPattern =
        r'^[\w-]+(?:\.[\w-]+)*@(?:[\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
}
