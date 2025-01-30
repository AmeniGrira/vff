import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'pass_page.dart'; // Assure-toi que le chemin est correct
 import 'delete_account_page.dart'; // Importer la page de suppression de compte

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  bool isLoading = false;
  String? errorMessage;
  XFile? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          userEmail = user.email;
        });
      } else {
        setState(() {
          userEmail = 'No user signed in';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedImagePath = prefs.getString('profile_image');
    if (storedImagePath != null) {
      setState(() {
        _image = XFile(storedImagePath);
      });
    }
  }

  void _saveProfileImage(XFile image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_image', image.path);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      _saveProfileImage(image);
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _deleteAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeleteAccountPage()),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PassPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Colors.blue.shade800)
              : errorMessage != null
              ? Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 16),
          )
              : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.person,
                        size: screenWidth * 0.2,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildSection(
                  title: 'User Email',
                  content: userEmail ?? 'Loading...',
                  icon: Icons.email,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildSectionTitle('Additional Information'),
                SizedBox(height: screenHeight * 0.02),
                _buildInfoCard('Name: John Doe', Icons.person),
                SizedBox(height: screenHeight * 0.02),
                _buildInfoCard('Description: Mobile Developer', Icons.description),
                SizedBox(height: screenHeight * 0.05),
                _buildCustomButton(
                  label: 'Change Password',
                  onPressed: _navigateToChangePassword,
                  color: Colors.blue.shade800,
                  icon: Icons.lock,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildCustomButton(
                  label: 'Logout',
                  onPressed: _logout,
                  color: Colors.red[400]!,
                  icon: Icons.logout,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildCustomButton(
                  label: 'Delete Account',
                  onPressed: _deleteAccount,
                  color: Colors.blueGrey[400]!,
                  icon: Icons.delete_forever,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.blue.shade800),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 18, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.blue.shade800),
          SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6.0,
        padding: EdgeInsets.symmetric(vertical: 15),
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }
}