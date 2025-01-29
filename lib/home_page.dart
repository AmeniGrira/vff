import 'dart:typed_data'; // Assure-toi que cette importation est nécessaire
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importer image_picker pour la caméra et galerie

class HomePage extends StatefulWidget {
  final Function(bool) onModeChanged;
  final Function(String?) onLanguageChanged;

  HomePage({Key? key, required this.onModeChanged, required this.onLanguageChanged})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final ImagePicker _picker = ImagePicker();
  Uint8List? rectoImage;
  Uint8List? versoImage;

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
              _buildButton(label: 'Insert Image', color: Colors.blue.shade400),
              SizedBox(height: screenHeight * 0.02),
              _buildButton(label: 'Validate Images', color: Colors.blue.shade800),
              SizedBox(height: screenHeight * 0.03),
              _buildResult(),
              SizedBox(height: screenHeight * 0.02),
              _buildImagesAfterValidation(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Méthode pour afficher le titre
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

  // Méthode pour afficher les sélecteurs d'images
  Widget _buildImageSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImageSelector(rectoImage, 'Recto'),
        SizedBox(width: 20),
        _buildImageSelector(versoImage, 'Verso'),
      ],
    );
  }

  // Méthode pour construire un sélecteur d'image
  Widget _buildImageSelector(Uint8List? imageBytes, String label) {
    return Card(
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
    );
  }

  // Méthode pour afficher un bouton
  Widget _buildButton({required String label, required Color color}) {
    return ElevatedButton(
      onPressed: () {
        _showImageSourceDialog(label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Utilise backgroundColor au lieu de primary
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  // Afficher un dialog pour choisir source de l'image (galerie ou caméra)
  Future<void> _showImageSourceDialog(String label) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select image source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(label, ImageSource.camera);
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(label, ImageSource.gallery);
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour sélectionner une image
  Future<void> _pickImage(String label, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (label == 'Recto') {
          rectoImage = bytes;
        } else if (label == 'Verso') {
          versoImage = bytes;
        }
      });
    }
  }

  // Méthode pour afficher le résultat de la reconnaissance (vide ici)
  Widget _buildResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No text detected',
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Méthode pour afficher les images après validation (vide ici)
  Widget _buildImagesAfterValidation() {
    return Column(
      children: [
        Text(
          "Validated recto image:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        // Placeholders for images
        _buildImageSelector(rectoImage, 'Validated Recto'),
        SizedBox(height: 20),
        Text(
          "Validated verso image:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _buildImageSelector(versoImage, 'Validated Verso'),
      ],
    );
  }

  // Méthode pour construire la barre de navigation inférieure
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
  }
}
