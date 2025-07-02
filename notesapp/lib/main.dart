import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesapp/views/editor_view.dart';
import 'package:notesapp/views/login_view.dart';
import 'firebase_options.dart';
import 'package:notesapp/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Authgate(),
    ),
  );
}

class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const Homepage();
        } else {
          return const LoginView();
        }
      },
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email, _password;
  bool _isLoading = false;
  String? _errorMessage;

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both fields';
      });
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });

      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
     final UserCredential =
         await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User Registered: $UserCredential.user?.uid");
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        //Navigator.pushReplacement(
          //context,
          //MaterialPageRoute(builder: (context) => const Homepage()),
        //);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'Weak-password') {
          _errorMessage = ' Your Password is too weak';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'This email is already registered';
        } else if (e.code == 'Invalid-email') {
          _errorMessage = 'Please enter a valid email';
        } else {
          _errorMessage = 'Registration failed. Please try again later: ${e.code}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again later.';
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
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.black,
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your Email here',
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password here',
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}


