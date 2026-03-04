import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Ensure you have run: flutter pub add intl

import '../../theme/app_theme.dart';
import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_logo.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import 'register_password_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const route = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Controller to handle the text inside the Birthdate field
  final TextEditingController _birthdateController = TextEditingController();

  File? _profileFile; // cropped result file

  // Function to show the Date Picker
  Future<void> _selectBirthdate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.teal, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats date to MM/DD/YYYY to match your requirements
        _birthdateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickAndCropProfile() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );

      if (picked == null) return;

      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressQuality: 92,
        maxWidth: 512,
        maxHeight: 512,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: AppTheme.teal,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: false,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped == null) return;

      setState(() {
        _profileFile = File(cropped.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick/crop image: $e')),
      );
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  void dispose() {
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 95, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NutechLogo(),
                const SizedBox(height: 18),

                // ✅ Profile circle slot
                Center(
                  child: InkWell(
                    onTap: _pickAndCropProfile,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _profileFile == null
                            ? Image.asset(
                                'assets/images/addimage.png',
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _profileFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _label('Name'),
                const NutechTextField(hint: 'Enter name'),
                const SizedBox(height: 16),

                _label('Email Address'),
                const NutechTextField(
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _label('Address'),
                const NutechTextField(hint: 'Enter address'),
                const SizedBox(height: 16),

                _label('Contact Number'),
                const NutechTextField(
                  hint: 'Enter contact number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _label('Birthdate'),
                NutechTextField(
                  hint: 'Select birthdate',
                  readOnly: true,
                  controller: _birthdateController,
                  onTap: _selectBirthdate, // Triggers calendar on tap
                  suffix: const Icon(Icons.calendar_month, color: AppTheme.teal),
                ),

                const SizedBox(height: 32),

                PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterPasswordScreen.route);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}