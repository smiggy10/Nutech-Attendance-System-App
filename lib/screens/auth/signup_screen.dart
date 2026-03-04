import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../utils/web_cropper_helper.dart'; 
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
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  File? _profileFile;
  String? _webImage;

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
              primary: AppTheme.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
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
          if (kIsWeb) getWebSettings(context),
        ],
      );

      if (cropped == null) return;

      setState(() {
        if (kIsWeb) {
          _webImage = cropped.path;
          _profileFile = File('web_image'); 
        } else {
          _profileFile = File(cropped.path);
        }
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
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Removed 'Scaffold' here because NutechBackground now provides it.
    // This prevents the background from moving when the keyboard opens.
    return NutechBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          // KeyboardDismissBehavior ensures keyboard hides when you scroll
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NutechLogo(),
              const SizedBox(height: 18),

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
                      child: (_webImage != null || _profileFile != null)
                          ? (kIsWeb 
                              ? Image.network(_webImage!, fit: BoxFit.cover) 
                              : Image.file(_profileFile!, fit: BoxFit.cover))
                          : Image.asset(
                              'assets/images/addimage.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _label('Name'),
              NutechTextField(
                hint: 'Enter name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              _label('Email Address'),
              NutechTextField(
                hint: 'Enter email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              _label('Address'),
              NutechTextField(
                hint: 'Enter address',
                controller: _addressController,
              ),
              const SizedBox(height: 16),

              _label('Contact Number'),
              NutechTextField(
                hint: 'Enter contact number',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 16),

              _label('Birthdate'),
              NutechTextField(
                hint: 'Select birthdate',
                readOnly: true,
                controller: _birthdateController,
                onTap: _selectBirthdate,
                suffix: const Icon(Icons.calendar_month, color: AppTheme.teal),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Continue',
                onPressed: () {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final address = _addressController.text.trim();
                  final phone = _phoneController.text.trim();
                  final birthdate = _birthdateController.text.trim();

                  if (name.isEmpty || email.isEmpty || address.isEmpty || phone.isEmpty || birthdate.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all details'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  if (phone.length != 11) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact number must be exactly 11 digits'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  if (_profileFile == null && _webImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload a profile photo'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final Map<String, dynamic> registrationData = {
                    'full_name': name,
                    'email': email,
                    'address': address,
                    'contact_number': phone,
                    'birthdate': birthdate,
                    'profile_image': kIsWeb ? _webImage : _profileFile,
                  };

                  Navigator.pushNamed(
                    context, 
                    RegisterPasswordScreen.route,
                    arguments: registrationData,
                  );
                },
              ),
              // Extra padding at the bottom for better scroll feel on 6.67" screens
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}