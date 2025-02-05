import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour utiliser FilteringTextInputFormatter

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // États pour gérer la visibilité du mot de passe
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Fonction pour sélectionner la date et vérifier l'âge
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime eighteenYearsAgo = now.subtract(Duration(days: 18 * 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null && pickedDate != now) {
      setState(() {
        _dobController.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  // Fonction pour créer un compte
  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // Simuler la création d'un compte
      final newUser = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'address': _addressController.text,
        'postal_code': _postalCodeController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'dob': _dobController.text,
        'cin': _cinController.text,
        'phone': _phoneController.text,
      };

      // Affichage d'une notification de succès (en lieu et place d'une action réelle)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account successfully created!'),
        backgroundColor: Colors.green,
      ));

      // Réinitialiser les champs après la création
      _formKey.currentState!.reset();
    }
  }

  @override
  void dispose() {
    // Libérer les contrôleurs
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _cinController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sign Up', style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField('Username', _usernameController, hint: 'Enter your username', icon: Icons.person),
                _buildTextField('Email', _emailController, isEmail: true, hint: 'Enter a valid email (e.g., user@example.com)', icon: Icons.email),
                _buildPasswordField('Password', _passwordController, hint: 'Password must be at least 6 characters', isPassword: true, icon: Icons.lock),
                _buildPasswordField('Confirm Password', _confirmPasswordController, hint: 'Confirm your password', isPassword: true, icon: Icons.lock),
                _buildTextField('First Name', _firstNameController, hint: 'Enter your first name', icon: Icons.person_outline),
                _buildTextField('Last Name', _lastNameController, hint: 'Enter your last name', icon: Icons.person_outline),
                _buildTextField('Address', _addressController, hint: 'Enter your address', icon: Icons.home),
                _buildTextField('Postal Code', _postalCodeController, hint: 'Enter postal code (e.g., 12345)', isNumeric: true, icon: Icons.map),
                _buildTextField('City', _cityController, hint: 'Enter your city', icon: Icons.location_city),
                _buildTextField('Country', _countryController, hint: 'Enter your country', icon: Icons.flag),
                _buildTextField('CIN', _cinController, hint: 'Enter your CIN (8 digits)', isNumeric: true, icon: Icons.credit_card),
                _buildTextField('Phone Number', _phoneController, hint: 'Enter phone number (8 digits)', isNumeric: true, icon: Icons.phone),
                _buildDateOfBirthField(),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _createAccount,
                  child: Text('Create Account', style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    shadowColor: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false, String? hint, bool isNumeric = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue.shade900),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blue.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: Icon(icon, color: Colors.blue.shade900),
        ),
        onChanged: (text) {
          setState(() {});
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (label == 'Postal Code' && !RegExp(r'^\d+$').hasMatch(value)) {
            return 'Postal Code must contain only numbers';
          }
          if (label == 'CIN' && !RegExp(r'^\d{8}$').hasMatch(value)) {
            return 'CIN must be exactly 8 digits';
          }
          if (label == 'Phone Number' && !RegExp(r'^\d{8}$').hasMatch(value)) {
            return 'Phone number must be exactly 8 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {required String hint, bool isPassword = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.blue.shade900),
          hintStyle: TextStyle(color: Colors.blue.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: Icon(icon, color: Colors.blue.shade900),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.blue.shade900,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'Select your date of birth',
          labelStyle: TextStyle(color: Colors.blue.shade900),
          hintStyle: TextStyle(color: Colors.blue.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade900),
        ),
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your date of birth';
          }
          return null;
        },
      ),
    );
  }
}
