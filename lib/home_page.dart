import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'contact_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
Future<String> _uploadImageToFirebaseStorage(Uint8List imageBytes, String imageName) async {
  try {
    // Create a reference to the Firebase Storage location
    final Reference storageReference = FirebaseStorage.instance.ref().child('cin_images/$imageName.png');

    // Upload the image
    final UploadTask uploadTask = storageReference.putData(imageBytes);

    // Wait for the upload to complete
    final TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  } catch (e) {
    print('Error uploading image: $e');
    throw e; // Handle the error as needed
  }
}
class HomePage extends StatefulWidget {
  final Function(bool) onModeChanged;
  final Function(String?) onLanguageChanged;

  const HomePage({Key? key, required this.onModeChanged, required this.onLanguageChanged})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  Uint8List? _rectoImage;
  Uint8List? _versoImage;
  String _recognizedText = '';
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'CIN Recognition',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitle(),
              SizedBox(height: screenHeight * 0.03),
              _buildImageSelectors(),
              SizedBox(height: screenHeight * 0.03),
              _buildButton(
                label: 'Insert Image',
                color: Colors.blue.shade400,
                onPressed: _chooseImageDialog,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildButton(
                label: 'Validate Images',
                color: Colors.blue.shade800,
                onPressed: _validateImages,
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildImagesAfterValidation(),
              SizedBox(height: screenHeight * 0.02),
              if (_recognizedText.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _recognizedText,
                    textAlign: TextAlign.right, // Affichage en direction RTL pour l'arabe
                    textDirection: TextDirection.rtl, // Direction du texte en arabe
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Recognize text on a CIN card (Recto and Verso)',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImageSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImageSelector(_rectoImage, 'Recto'),
        SizedBox(width: 20),
        _buildImageSelector(_versoImage, 'Verso'),
      ],
    );
  }

  Widget _buildImageSelector(Uint8List? imageBytes, String label) {
    return GestureDetector(
      onTap: () => _chooseImage(label),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageBytes != null
                      ? Image.memory(
                    imageBytes,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseImage(String label) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        if (label == 'Recto') {
          _rectoImage = imageBytes;
        } else {
          _versoImage = imageBytes;
        }
      });
    }
  }

  Widget _buildButton({required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildImagesAfterValidation() {
    return Column(
      children: [
        Text(
          "Validated recto image:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _buildImageSelector(_rectoImage, 'Validated Recto'),
        SizedBox(height: 20),
        Text(
          "Validated verso image:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _buildImageSelector(_versoImage, 'Validated Verso'),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_mail),
          label: 'Contact',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }


  // Méthode pour naviguer vers une autre page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _navigateToPage(SettingsPage(
        onModeChanged: widget.onModeChanged,
        onLanguageChanged: widget.onLanguageChanged,
      ));
    } else if (index == 1) {
      _navigateToPage(ContactServicePage());
    } else if (index == 2) {
      _navigateToPage(ProfilePage());
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

// Navigate to different pages based on index


  Future<void> _validateImages() async {
    if (_rectoImage == null && _versoImage == null) {
      setState(() {
        _recognizedText = 'No images selected';
      });
      return;
    }

    final recognizedTexts = <String>[];
    final textRecognizer = TextRecognizer();

    for (final imageBytes in [_rectoImage, _versoImage]) {
      if (imageBytes != null) {
        final inputImage = InputImage.fromFilePath(await _writeImageToFile(imageBytes));
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        recognizedTexts.add(_extractRecognizedText(recognizedText));
      }
    }

    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedTexts.join('\n');
    });

    // Save to Firebase
    await FirebaseFirestore.instance.collection('CIN').add({
      'text': _recognizedText,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _writeImageToFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/temp_image.png';
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(imageBytes);
    return tempFilePath;
  }

  String _extractRecognizedText(RecognizedText recognizedText) {
    String text = '';
    for (TextBlock block in recognizedText.blocks) {
      text += '${block.text}\n'; // Affichage du texte reconnu
    }
    return text;
  }

  Future<void> _chooseImageDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an image"),
          content: Text("Select an image from the gallery or use the camera."),
          actions: <Widget>[
            TextButton(
              child: Text("Gallery"),
              onPressed: () {
                _chooseImage('Recto');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Camera"),
              onPressed: () {
                _chooseImageFromCamera('Recto');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _chooseImageFromCamera(String label) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        if (label == 'Recto') {
          _rectoImage = imageBytes;
        } else {
          _versoImage = imageBytes;
        }
      });
    }
  }
}
