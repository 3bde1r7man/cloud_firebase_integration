import 'package:cloud_firebase_integration/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _showEmailFields = false;
  bool _showPhoneFields = false;

  // Email/Password Sign-Up
  Future<void> _signUpWithEmailPassword() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created Successfully")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Google Sign-Up
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signed In with Google")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Phone Number Sign-Up
  Future<void> _signUpWithPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone Verification Complete")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPPage(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Email Fields
                if (_showEmailFields) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signUpWithEmailPassword,
                    child: const Text("Sign Up with Email/Password"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showEmailFields = false;
                      });
                    },
                    child: const Text("Back"),
                  ),
                ],

                // Phone Number Fields
                if (_showPhoneFields) ...[
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signUpWithPhoneNumber,
                    child: const Text("Sign Up with Phone Number"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showPhoneFields = false;
                      });
                    },
                    child: const Text("Back"),
                  ),
                ],

                // Initial Options
                if (!_showEmailFields && !_showPhoneFields) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showEmailFields = true;
                      });
                    },
                    child: const Text("Sign Up with Email/Password"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text("Sign Up with Google"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPhoneFields = true;
                      });
                    },
                    child: const Text("Sign Up with Phone Number"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text("Already have an account? Log in"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
