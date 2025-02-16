import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_voter_call/pages/otp_verify_page.dart';
import 'package:team_voter_call/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _signInWithMobile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final mobileNumber = '+91${_mobileController.text}'; // Add +91 country code

    if (!isValidMobileNumber(_mobileController.text)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    try {
      // final res = await SupabaseService.isTeamMember(
      //   mobileNumber,
      // );
      // if (res) {
      await supabase.auth.signInWithOtp(
        phone: mobileNumber,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OTPVerifyPage(mobileNumber: mobileNumber),
          ),
        );
        // }
      }
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isValidMobileNumber(String mobile) {
    return mobile.length == 10 && int.tryParse(mobile) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Login with Mobile Number',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number (10 digits)',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.red), // Red
                      backgroundColor: Colors.blue, // Blue background
                    )
                  : ElevatedButton(
                      onPressed: _signInWithMobile,
                      child: const Text('Send OTP'),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
