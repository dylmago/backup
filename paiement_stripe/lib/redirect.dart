import 'package:flutter/material.dart';
//import 'package:paiement_stripe/achat_page.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/firstscreen.dart';
//import 'package:paiement_stripe/paiement_stripe.dart';

class RedirectPage extends StatelessWidget {
  final _authService = AuthService();
  static String email;
  static String token;
  static String sessionID;

  RedirectPage(String mail, String tok) {
    email = mail;
    token = tok;
  }

  RedirectPage.fromGoCl(String mail, String tok, String sid) {
    email = mail;
    token = tok;
    sessionID = sid;
  }

  @override
  Widget build(BuildContext context) {
    redirect(context);
    return Container(

    );
  }

  redirect(BuildContext context) async {
    await _authService.reconnect(email, token);
    //await _authService.getProducts();
    await _authService.getInv();
    if(sessionID != null) {
      print("payement Gocardless !!!!");
      await _authService.confirmRedirectFlowGCL(sessionID);
    }
    //return Navigator.push(context, MaterialPageRoute(builder: (context) => PageAchat()));
    return Navigator.push(context, MaterialPageRoute(builder: (context) => FirstScreen()));
  }
}