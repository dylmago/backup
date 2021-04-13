import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_credentials.dart';

class SignUpPage extends StatefulWidget {
  final ValueChanged<SignUpCredentials> didProvideCredentials;
  final VoidCallback shouldShowLogin;

  SignUpPage({Key key, this.didProvideCredentials, this.shouldShowLogin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          child: Stack(children: [
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(10),
              child: Text("Enregistrez-vous", style: Theme.of(context).textTheme.headline4),
            ),
            // Sign Up Form
            Form(
              key: _formKey,
              child: _signUpForm(),
            ),
            // Login Button
            Container(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                  onPressed: widget.shouldShowLogin,
                  child: Text('Already have an account? Login.')),
            )
          ])),
    );
  }

  Widget _signUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Email TextField
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        // Password TextField
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(icon: Icon(Icons.lock_open), labelText: 'Password'),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        // Sign Up Button
        TextButton(
          onPressed: () {
            if(_formKey.currentState.validate()) _signUp();
          },
          child: Text('Sign Up'),
          //color: Theme.of(context).accentColor)
          style: ButtonStyle(
            foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled) ? null : Colors.black;
            }),
            backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled) ? null : Colors.blue;
            }),
          ),
        )
      ],
    );
  }

  void _signUp() {
    //final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    //final credentials = SignUpCredentials(username: username, email: email, password: password);
    final credentials = SignUpCredentials(email: email, password: password);
    widget.didProvideCredentials(credentials);
  }
}