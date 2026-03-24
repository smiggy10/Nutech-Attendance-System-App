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

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _birthdateFocus = FocusNode();

  File? _profileFile;
  String? _webImage;

  String? _nameError;
  String? _emailError;
  String? _addressError;
  String? _phoneError;
  String? _birthdateError;
  String? _photoError;

  bool _isValidFullName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final nameRegex = RegExp(r'^[A-Za-z.\s]+$');
    return nameRegex.hasMatch(trimmed);
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}$',
    );
    return emailRegex.hasMatch(trimmed);
  }

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

  /// Helper to show selection dialog between Camera and Gallery
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.teal),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropProfile(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.teal),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropProfile(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropProfile(ImageSource source) async {
    try {
      debugPrint('Starting image picker with source: $source');

      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
      );

      if (picked == null) {
        debugPrint('No image selected');
        return;
      }

      debugPrint('Image picked: ${picked.path}');
      debugPrint('Running on web: $kIsWeb');

      if (kIsWeb) {
        debugWebCropper();
      }

      debugPrint('Starting image cropper...');
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

      debugPrint(
        'Cropping completed. Result: ${cropped != null ? 'success' : 'cancelled'}',
      );

      if (cropped == null) {
        debugPrint('User cancelled cropping');
        return;
      }

      setState(() {
        if (kIsWeb) {
          _webImage = cropped.path;
          _profileFile = File('web_image');
          debugPrint('Web image set: $_webImage');
        } else {
          _profileFile = File(cropped.path);
          debugPrint('Mobile file set: ${_profileFile!.path}');
        }
        _photoError = null;
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _pickAndCropProfile: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick/crop image: $e')));
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  void _showBottomToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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

    _nameFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _birthdateFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NutechBackground(
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NutechLogo(),
                    const SizedBox(height: 18),

                    Center(
                      child: InkWell(
                        onTap: _showImageSourceDialog,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _photoError != null
                                  ? Colors.redAccent
                                  : Colors.white,
                              width: 3,
                            ),
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
                                    ? Image.network(
                                        _webImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _profileFile!,
                                        fit: BoxFit.cover,
                                      ))
                                : Image.asset(
                                    'assets/images/addimage.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _label('Full Name'),
                    NutechTextField(
                      hint: 'Enter Full Name',
                      controller: _nameController,
                      focusNode: _nameFocus,
                      errorText: _nameError,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Email Address'),
                    NutechTextField(
                      hint: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Address'),
                    NutechTextField(
                      hint: 'Enter address',
                      controller: _addressController,
                      focusNode: _addressFocus,
                      errorText: _addressError,
                      onChanged: (_) {
                        if (_addressError != null) {
                          setState(() => _addressError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Contact Number'),
                    NutechTextField(
                      hint: 'Enter contact number',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      errorText: _phoneError,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Birthdate'),
                    NutechTextField(
                      hint: 'Select birthdate',
                      readOnly: true,
                      controller: _birthdateController,
                      focusNode: _birthdateFocus,
                      errorText: _birthdateError,
                      onTap: () async {
                        if (_birthdateError != null) {
                          setState(() => _birthdateError = null);
                        }
                        await _selectBirthdate();
                      },
                      suffix: const Icon(
                        Icons.calendar_month,
                        color: AppTheme.teal,
                      ),
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

                        setState(() {
                          _nameError = null;
                          _emailError = null;
                          _addressError = null;
                          _phoneError = null;
                          _birthdateError = null;
                          _photoError = null;
                        });

                        if (name.isEmpty) {
                          setState(() => _nameError = 'Full Name is required.');
                          _nameFocus.requestFocus();
                          return;
                        }
                        if (email.isEmpty) {
                          setState(
                            () => _emailError = 'Email Address is required.',
                          );
                          _emailFocus.requestFocus();
                          return;
                        }
                        if (address.isEmpty) {
                          setState(
                            () => _addressError = 'Address is required.',
                          );
                          _addressFocus.requestFocus();
                          return;
                        }
                        if (phone.isEmpty) {
                          setState(
                            () => _phoneError = 'Contact Number is required.',
                          );
                          _phoneFocus.requestFocus();
                          return;
                        }
                        if (birthdate.isEmpty) {
                          setState(
                            () => _birthdateError = 'Birthdate is required.',
                          );
                          _birthdateFocus.requestFocus();
                          return;
                        }

                        if (!_isValidFullName(name)) {
                          setState(() {
                            _nameError =
                                'Full Name can only contain letters, spaces, and periods.';
                          });
                          _nameFocus.requestFocus();
                          return;
                        }

                        if (!_isValidEmail(email)) {
                          setState(() {
                            _emailError = 'Please enter a valid email address.';
                          });
                          _emailFocus.requestFocus();
                          return;
                        }

                        if (phone.length != 11) {
                          setState(() {
                            _phoneError =
                                'Please enter a valid contact number.';
                          });
                          _phoneFocus.requestFocus();
                          return;
                        }

                        if (_profileFile == null && _webImage == null) {
                          final msg =
                              'Please upload your photo before continuing.';
                          setState(() => _photoError = msg);
                          _showBottomToast(msg);
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}