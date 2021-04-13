import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/compagny_page.dart';
import 'package:paiement_stripe/firstscreen.dart';
import 'package:paiement_stripe/login_page.dart';
//import 'package:paiement_stripe/nav_section.dart';
//import 'package:paiement_stripe/paiement_stripe.dart';
import 'package:paiement_stripe/profile_page.dart';
import 'package:paiement_stripe/sign_up_page.dart';
import 'package:paiement_stripe/verification_page.dart';
import 'package:paiement_stripe/redirect.dart';
//import 'package:paiement_stripe/approbation.dart';

void main() {
  runApp(MyApp());
  //imageCache.clear();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
      ],
      routes: {
        '/': (context) => Authentication(),
        '/home': (context) => FirstScreen(),
        /*'/profile': (context) => ProfilePage(),
        '/company': (context) => CompagnyCreatePage(),
        '/approbation': (context) => UserApprobationPage(),
        '/paiement': (context) => PaiementStripeWebPage(),
        '/companies': (context) => UserCompaniesPage(),*/
      },
      onGenerateRoute: (settings) {
        List<String> pathComponents = settings.name.split('/');
        if((pathComponents[1] == "cancel" || pathComponents[1] == "success") && pathComponents.length==4) {
          return MaterialPageRoute(
            builder: (context) => RedirectPage(pathComponents[2], pathComponents.last)
          );
        }
        if(pathComponents[1] == "mandat") {
          print(pathComponents);
          //je n'ai pas le sessionID
          return MaterialPageRoute(
            builder: (context) => RedirectPage.fromGoCl(pathComponents[2], pathComponents[3], "")
          );
        }
        return null;
      },
    );
  }
}

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.showLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentification',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: StreamBuilder<AuthState>(
        stream: _authService.authStateController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Navigator(
              pages: [
                // Show Login Page
                if (snapshot.data.authFlowStatus == AuthFlowStatus.login) 
                  MaterialPage(child: LoginPage(
                    didProvideCredentials: _authService.login, 
                    shouldShowSignUp: _authService.showSignUp)
                  ),

                // Show Sign Up Page
                if (snapshot.data.authFlowStatus == AuthFlowStatus.signUp) 
                  MaterialPage(child: SignUpPage(
                    didProvideCredentials: _authService.signUp,
                    shouldShowLogin: _authService.showLogin)
                  ),
                // Show Verification Code Page
                if (snapshot.data.authFlowStatus == AuthFlowStatus.verification)
                  MaterialPage(child: VerificationPage(didProvideVerificationCode: _authService.verifyCode)),

                if(snapshot.data.authFlowStatus == AuthFlowStatus.session)
                  MaterialPage(child: RouterPage()),
                  //MaterialPage(child: HomePage()),
              ],
              onPopPage: (route, result) => route.didPop(result),
            );
          } else {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
    );
  }
}

class RouterPage extends StatefulWidget {
  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {

  @override
  Widget build(BuildContext context) {
    print("Status à l'entrée de la RouterPage");
    print(status.stat);
    return Navigator(
      pages: [
        if(status.stat == 1) MaterialPage(child: ProfilePage()),

        if(status.stat == 2) MaterialPage(child: CompagnyHomePage()),

        if(status.stat == 301 || status.stat == 310) MaterialPage(child: WaitingPage()),

        if(status.stat == 300) MaterialPage(child: FirstScreen()),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

