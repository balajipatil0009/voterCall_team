import 'package:flutter/material.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_voter_call/pages/home_page.dart';

class OTPVerifyPage extends StatefulWidget {
  final String mobileNumber;
  const OTPVerifyPage({Key? key, required this.mobileNumber}) : super(key: key);

  @override
  State<OTPVerifyPage> createState() => _OTPVerifyPageState();
}

class _OTPVerifyPageState extends State<OTPVerifyPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;
  bool _isTimerActive = true;
  Timer? _timer;
  bool _canResendOTP = false;
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timerSeconds = 60;
    _isTimerActive = true;
    _canResendOTP = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
          _canResendOTP = true;
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter OTP';
      });
      return;
    }

    try {
      final response = await supabase.auth
        ..verifyOTP(
          phone: widget.mobileNumber,
          token: otp,
          type: OtpType.sms,
        );
      if (response.currentUser != null) {
        // Get the current user after OTP verification
        final user = supabase.auth.currentUser;

        if (user != null) {
          // Insert user ID and mobile number into the voter_user table
          await supabase.from('team_members').upsert({
            'id': user.id,
            'phone_number': widget.mobileNumber,
          });

          // Navigate to the home screen after successful OTP verification and database insertion
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(), // Replace with your home page
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to retrieve user after OTP verification.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to verify OTP. Please try again.';
        });
      }
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unexpected error occurred {$error}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return; // Prevent resending before timer ends
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.signInWithOtp(
        phone: widget.mobileNumber,
      );
      _startTimer(); // Restart timer after resending
      setState(() {
        _canResendOTP = false; // Disable resend button temporarily
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully!')),
      );
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unexpected error occurred while resending OTP';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Verify OTP sent to ${widget.mobileNumber}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6, // OTP length is usually 6 digits
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
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
                      onPressed: _verifyOTP,
                      child: const Text('Verify OTP'),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              _isTimerActive
                  ? Text('Resend OTP in $_timerSeconds seconds')
                  : TextButton(
                      onPressed: _canResendOTP ? _resendOTP : null,
                      child: const Text('Resend OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
