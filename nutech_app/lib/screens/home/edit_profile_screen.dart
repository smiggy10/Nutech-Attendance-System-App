import 'package:flutter/material.dart';

import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';
import 'package:nutech_app/widgets/nutech_text_field.dart';
import 'package:nutech_app/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const route = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  final _userId = TextEditingController(text: 'EMP26N001');
  final _name = TextEditingController(text: 'Juan Reynolds');
  final _email = TextEditingController(text: 'juan.reynolds@gmail.com');
  final _address = TextEditingController(text: 'Marauoy, Lipa City, Batangas');
  final _contact = TextEditingController(text: '0912 345 6789');
  final _birthdate = TextEditingController(text: '01/01/1999');

  // Keep initial values so we can detect "unsaved changes"
  late final Map<String, String> _initial;

  bool get _isDirty {
    return _userId.text != _initial['userId'] ||
        _name.text != _initial['name'] ||
        _email.text != _initial['email'] ||
        _address.text != _initial['address'] ||
        _contact.text != _initial['contact'] ||
        _birthdate.text != _initial['birthdate'];
  }

  @override
  void initState() {
    super.initState();
    _initial = {
      'userId': _userId.text,
      'name': _name.text,
      'email': _email.text,
      'address': _address.text,
      'contact': _contact.text,
      'birthdate': _birthdate.text,
    };

    // Rebuild so back button can react to dirty state
    for (final c in [_userId, _name, _email, _address, _contact, _birthdate]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _userId.dispose();
    _name.dispose();
    _email.dispose();
    _address.dispose();
    _contact.dispose();
    _birthdate.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    // parse MM/dd/yyyy -> best-effort
    DateTime initialDate = DateTime(1999, 1, 1);
    final parts = _birthdate.text.split('/');
    if (parts.length == 3) {
      final mm = int.tryParse(parts[0]);
      final dd = int.tryParse(parts[1]);
      final yy = int.tryParse(parts[2]);
      if (mm != null && dd != null && yy != null) {
        initialDate = DateTime(yy, mm, dd);
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    final mm = picked.month.toString().padLeft(2, '0');
    final dd = picked.day.toString().padLeft(2, '0');
    final yy = picked.year.toString();
    _birthdate.text = '$mm/$dd/$yy';
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          'WARNING',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text("Are you sure you don’t want to save changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _handleBack() async {
    final canLeave = await _confirmDiscardChanges();
    if (!mounted) return;
    if (canLeave) Navigator.pop(context);
  }

  void _saveChanges() {
    // Frontend-only: just "pretend save"
    // If you later connect backend, call API here, then update _initial.
    _initial['userId'] = _userId.text;
    _initial['name'] = _name.text;
    _initial['email'] = _email.text;
    _initial['address'] = _address.text;
    _initial['contact'] = _contact.text;
    _initial['birthdate'] = _birthdate.text;

    setState(() {});
    Navigator.pop(context); // go back to Profile after save
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // we handle back ourselves
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: NutechBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar like the mock: back arrow + centered title
                  Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance the IconButton space
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Avatar with small camera icon
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundImage: AssetImage('assets/images/ui/avatar.png'),
                          backgroundColor: Colors.white,
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  _label('User ID'),
                  NutechTextField(
                    controller: _userId,
                    hint: 'EMP26N001',
                  ),
                  const SizedBox(height: 14),

                  _label('Name'),
                  NutechTextField(
                    controller: _name,
                    hint: 'Enter name',
                  ),
                  const SizedBox(height: 14),

                  _label('Email'),
                  NutechTextField(
                    controller: _email,
                    hint: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  _label('Address'),
                  NutechTextField(
                    controller: _address,
                    hint: 'Enter address',
                  ),
                  const SizedBox(height: 14),

                  _label('Contact no.'),
                  NutechTextField(
                    controller: _contact,
                    hint: 'Enter contact number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  _label('Birthdate'),
                  NutechTextField(
                    controller: _birthdate,
                    hint: 'Enter birthdate',
                    readOnly: true,
                    onTap: _pickBirthdate,
                    suffix: IconButton(
                      onPressed: _pickBirthdate,
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),

                  const SizedBox(height: 22),

                  PrimaryButton(
                    label: 'Save Changes',
                    onPressed: _saveChanges,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}