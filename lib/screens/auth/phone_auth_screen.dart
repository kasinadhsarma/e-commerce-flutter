import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isCodeSent = false;
  String? _verificationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _verifyPhone() {
    if (_phoneFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.verifyPhoneNumber(
        _phoneController.text.trim(),
        (verificationId) {
          setState(() {
            _isCodeSent = true;
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
      );
    }
  }

  void _verifyCode() {
    if (_verificationFormKey.currentState!.validate() && _verificationId != null) {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.confirmPhoneVerification(
        _verificationId!,
        _codeController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthLoading = authProvider.status == AuthStatus.loading;
    final isLoading = _isLoading || isAuthLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Phone Authentication'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isCodeSent
              ? _buildVerificationForm(context, authProvider, isLoading)
              : _buildPhoneForm(context, authProvider, isLoading),
        ),
      ),
    );
  }

  Widget _buildPhoneForm(BuildContext context, AuthProvider authProvider, bool isLoading) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'We\'ll send a verification code to your phone number.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Error message if any
          if (authProvider.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                authProvider.errorMessage!,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          if (authProvider.errorMessage != null)
            const SizedBox(height: 16),
          
          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+1 123 456 7890',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              // Basic phone number validation
              if (!value.contains(RegExp(r'^\+?[0-9]{10,15}$'))) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 24),
          
          // Send code button
          ElevatedButton(
            onPressed: isLoading ? null : _verifyPhone,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Verification Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationForm(BuildContext context, AuthProvider authProvider, bool isLoading) {
    return Form(
      key: _verificationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verification code sent to ${_phoneController.text}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => _isCodeSent = false),
            child: const Text('Change phone number?'),
          ),
          const SizedBox(height: 16),
          
          // Error message if any
          if (authProvider.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                authProvider.errorMessage!,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          if (authProvider.errorMessage != null)
            const SizedBox(height: 16),
          
          // Code field
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              hintText: '123456',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length < 4 || value.length > 8) {
                return 'Please enter a valid verification code';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 24),
          
          // Verify code button
          ElevatedButton(
            onPressed: isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify Code'),
          ),
          const SizedBox(height: 16),
          
          // Resend code button
          TextButton(
            onPressed: isLoading ? null : _verifyPhone,
            child: const Text('Resend Code'),
          ),
        ],
      ),
    );
  }
}