import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/main.dart';
import 'package:notesapp/views/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email, _password;
  String? _errorMessage;

  @override
  void initState() {
    _email = TextEditingController();
     _password = TextEditingController();
    super.initState();
  } 

  @override
  void dispose() {
 _email.dispose();
 _password.dispose();
    super.dispose();
  }

  Future<void> _login  () async {
    final email = _email.text;
    final password = _password.text;
    setState(() {
      _errorMessage = null;
    });
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both fields';
      });
      return;
    }
    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }
    try {
      setState(() {
        //_isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email:
       email, password: password);
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homepage(),
        ),
       );
    } on FirebaseAuthException catch (e) {
      print('Login error code :${e.code}');
      setState(() {
        if (e.code == 'user-not-found' || e.code =='invalid-credential' || e.code =='wrong password') {
          _errorMessage = 'Invalid email or password. Please try again.' ;
        } 
        else if(e.code == 'invalid-email'){
          _errorMessage = 'The email address is not valid.';
        }
        else {
          _errorMessage = 'An error occurred. Please try again.(${e.code})';
        }
      });
    } finally {
      setState(() {
       // _isLoading = false;
      });
    }
    

    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor:Colors.black ,
        backgroundColor: Colors.tealAccent,
        title: const Text('Login'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0),
       child: Column(
          children: [
            TextField(
              controller: _email,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter Email here'
              ),
            ),
            TextField(
              controller: _password,
              autocorrect: false,
              enableSuggestions: false,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter password here'
              ),
            ),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterView(),
                  ),
                );
              },
              child: const Text('New User? Register here'),
            ),
            ],
          ),
          
        ),
      );
  }

}