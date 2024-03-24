import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChangeInformationScreen extends StatefulWidget {
  @override
  _ChangeInformationScreenState createState() => _ChangeInformationScreenState();
}

class _ChangeInformationScreenState extends State<ChangeInformationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _displayName;
  DateTime? _selectedDate;
  String? _imageUrl;

  TextEditingController displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    User? user = _auth.currentUser;
    _displayName = user?.displayName;
    displayNameController.text = _displayName ?? '';

    // TODO: Lấy ngày sinh và hình đại diện từ Firestore
    // _selectedDate = ...;
    // _imageUrl = ...;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? 'Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Select Date of Birth',
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // TODO: Thêm phần để tải hình đại diện và hiển thị ảnh
            // Example:
            // _imageUrl != null ? Image.network(_imageUrl!) : Container(),
            // ElevatedButton(
            //   onPressed: () => _pickImage(),
            //   child: Text('Pick Image'),
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Thêm phương thức để tải hình đại diện
  // void _pickImage() async {
  //   // TODO: Implement the image picking logic
  // }

  Future<void> _saveChanges() async {
    try {
      // TODO: Lưu các thay đổi vào Firestore và FirebaseAuth
      User? user = _auth.currentUser;

      // Update display name
      await user?.updateDisplayName(displayNameController.text);

      // Update date of birth and profile picture in Firestore
      // _firestore.collection('users').doc(user?.uid).set({
      //   'displayName': displayNameController.text,
      //   'dateOfBirth': _selectedDate,
      //   'profilePicture': _imageUrl,
      // });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Changes saved successfully!'),
      ));

      // Đóng trang ChangeInformationScreen và quay lại trang ProfileScreen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save changes.'),
      ));
    }
  }
}
