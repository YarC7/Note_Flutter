import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _auth = FirebaseAuth.instance;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                handleChangePassword();
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void handleChangePassword() async {
    try {
      // Kiểm tra xem mật khẩu cũ có đúng không
      User user = _auth.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Kiểm tra xem mật khẩu mới và xác nhận mật khẩu mới có khớp không
      if (newPasswordController.text == confirmPasswordController.text) {
        // Thực hiện logic thay đổi mật khẩu
        await user.updatePassword(newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password changed successfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('New passwords do not match!'),
        ));
      }Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to change password. Please check your current password.'),
      ));
    }
  }
}
