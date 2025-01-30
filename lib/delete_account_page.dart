import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importez Firebase Auth

class DeleteAccountPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer le compte'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenSize.width * 0.05),
            ),
            SizedBox(height: screenSize.height * 0.05),
            ElevatedButton(
              onPressed: () => _confirmDelete(context),
              child: Text('Supprimer le compte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.2,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher la boîte de dialogue de confirmation
  Future<void> _confirmDelete(BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer votre compte ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Oui, supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await _auth.currentUser!.delete(); // Supprime l'utilisateur actuel
        // Redirige vers la page de connexion après suppression
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        // Gestion des erreurs possibles lors de la suppression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du compte: $e')),
        );
      }
    }
  }
}