import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_credentials.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/firstscreen.dart';

class LoginPage extends StatefulWidget {
  final ValueChanged<LoginCredentials> didProvideCredentials;
  final VoidCallback shouldShowSignUp;

  LoginPage({Key key, this.didProvideCredentials, this.shouldShowSignUp}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String msgError = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40), //remplissage
          child: Stack(children: [
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(10),
              child: Text("Connectez-vous", style: Theme.of(context).textTheme.headline4),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Form
                Form(
                  key: _formKey,
                  child: _loginForm(),
                ),
                SizedBox(height: 10),
                _signInButton(),
              ],
            ),
            // Sign Up Button
            Container(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                  onPressed: widget.shouldShowSignUp,
                  child: Text('Don\'t have an account? Sign up.')),
            ),
          ])
        ),
    );
  }

  Widget _loginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Email TextField
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        // Password TextField
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(icon: Icon(Icons.lock_open), labelText: 'Password'),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        SizedBox(height: 5),
        Text(msgError, style: TextStyle(color: Colors.red),),
        SizedBox(height: 5),
        // Login Button
        TextButton(
          onPressed: () {
            if(_formKey.currentState.validate()) _login();
          },
          child: Text('Login'),
          style: ButtonStyle(
            foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled) ? null : Colors.black;
            }),
            backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled) ? null : Colors.blue;
            }),
          ),
        ),
      ],
    );
  }

  Widget _signInButton() {
    return OutlinedButton(
      onPressed: signIn,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        side: BorderSide(color: Colors.grey),
        elevation: 0,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final credentials = LoginCredentials(username: username, password: password);
    widget.didProvideCredentials(credentials);
  }

  void signIn() {
    _authService.signInWithGoogle().then((result) {
      if(result != null) {
        print("Connecté à Google");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FirstScreen();
            },
          ),
        );
      }
    });
  }
}