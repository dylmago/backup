import 'package:flutter/material.dart';
//import 'package:paiement_stripe/achat_page.dart';
import 'package:paiement_stripe/services/auth_service.dart';
//import 'package:paiement_stripe/firstscreen.dart';
import 'package:paiement_stripe/nav_section.dart';
//import 'package:paiement_stripe/models/Product.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'Stripe/stripe_stub.dart'
    //if (dart.library.io) 'Stripe/stripe_mobile.dart'
    if (dart.library.js) "Stripe/stripe_web.dart" as impl;

class PaiementStripeMobilePage extends StatefulWidget {
  @override
  _PaiementStripeMobilePageState createState() => _PaiementStripeMobilePageState();
}

class _PaiementStripeMobilePageState extends State<PaiementStripeMobilePage> {
  Widget navSection = NavSection();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNumberController = new TextEditingController();
  TextEditingController expYearController = new TextEditingController();
  TextEditingController expMonthController = new TextEditingController();
  TextEditingController cvcController = new TextEditingController();

  String msgError;

  @override
  void initState() {
    super.initState();
    msgError = "";
    StripePayment.setOptions(
      StripeOptions(publishableKey: "pk_test_51IONRVL8RLtMYo50Kg7037pCRaIjOlPViRShyzumivKxJQBu5un9iSOHcpUGv5yS4x42GJcLOW3oi87Kq0919amW00uswswXjP", merchantId: "Test", androidPayMode: 'test')
    );
    //panier = [];
    //disabled = true;
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paiement Stripe ',
      home: Scaffold(            
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black,
          ),                    
          title: navSection,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 5),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("Votre panier: ", style: Theme.of(context).textTheme.headline4),
                ),
                Column(
                  children: List.generate(
                    panier.length, 
                    (index) => Card(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Produit: ", style: TextStyle(fontSize: 20)),
                                //Text(panier[index].subscriptionName)
                                Text(panier[index].dbName.value.toString())
                              ],
                            ),
                            Row(
                              children: [
                                Text("Prix: ", style: TextStyle(fontSize: 20)),
                                //Text(panier[index].price.toString()),
                                Text(panier[index].backupPrice.value.toString()),
                                //Text(" euros")
                              ],
                            ),
                            Row(
                              children: [
                                //Text("Base de données: ", style: TextStyle(fontSize: 20)),
                                //Text(panier[index].dbName)
                                Text("hostname: ", style: TextStyle(fontSize: 20)),
                                Text(panier[index].hostname.value.toString())
                              ],
                            ),
                            Row(
                              children: [
                                Text("Taille: ", style: TextStyle(fontSize: 20)),
                                //Text(panier[index].dbSize)
                                Text(panier[index].dbSize.value.toString())
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                panier.removeAt(index);
                                print(panier);
                                setState(() {
                                  //navSection = NavSection();
                                });
                                _formKey.currentState.save();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Text("Retirer du panier"),
                              ),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  return states.contains(MaterialState.disabled) ? null : Colors.white;
                                }),
                                backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  return states.contains(MaterialState.disabled) ? null : Colors.red;
                                }),
                              ),
                            )
                          ]
                        )
                      ) 
                    )
                  )
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("Informations de paiement: ", style: Theme.of(context).textTheme.headline6),
                ),
                TextFormField(
                  controller: cardNumberController,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    if(!validCard(value)) {
                      return 'Enter a correct card number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: expMonthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Expired Month'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    if(!validExpMonth(value)) {
                      return 'Enter a correct exp month';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: expYearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Expired Year'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    if(!validExpYear(value)) {
                      return 'Enter a correct exp year (2025)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cvcController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'CVC'),
                  validator: (value) {
                    if(!validCVC(value)) {
                      return 'Enter a correct CVC (123)';
                    }
                    return null;
                  },
                ),
                Text(msgError, style: TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: panier.length==0 ? null : () async {
                    _formKey.currentState.save();
                    if (_formKey.currentState.validate()) {
                      CreditCard testCard;
                      if(cvcController.text.isEmpty) {
                        print("carte sans cvc");
                        testCard =  CreditCard(
                          number: cardNumberController.text,
                          expMonth: int.parse(expMonthController.text),
                          expYear: int.parse(expYearController.text)
                        );
                      }
                      else {
                        print("carte avec cvc");
                        testCard =  CreditCard(
                          number: cardNumberController.text,
                          expMonth: int.parse(expMonthController.text),
                          expYear: int.parse(expYearController.text),
                          cvc: cvcController.text
                        );
                      }
                      StripePayment.createTokenWithCard(testCard).then(
                        (token) async {
                          print("token créé !!!!");
                          String rep = await _authService.emitPaymentToServer(token.tokenId);
                          if(rep == "Tout est ok ") {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => PageAchat()));
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => FirstScreen()));
                            Navigator.of(context).pop();
                          }
                          else {
                            msgError = "il y a eu une erreur !!!!!";
                            print("réponse reçue");
                            print(rep);
                            setState(() {
                              
                            });
                          }
                        }
                      );
                    }
                  },
                  child: Text("Valider"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled) ? null : Colors.black;
                    }),
                    backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled) ? null : Colors.blue;
                    }),
                  ), 
                ),
              ]
            )
          )
        ),  
      )
    );
  }

  bool validExpMonth(exp) {
    if(RegExp(r'^(\d{2})$').hasMatch(exp)) {
      if(int.parse(exp) > 0 && int.parse(exp) <= 12) return true;
      else return false;
    }
    else return false;
    
  }

  bool validExpYear(exp) {
    var now = DateTime.now();
    if(RegExp(r'^(\d{4})$').hasMatch(exp)) {
      if(int.parse(exp) >= now.year) return true;
      else return false;
    }
    else return false;
  }

  bool validCard(cnum) {
    cnum = cnum.replaceAll(" ", "");
    return RegExp(
      r'^(\d{16})$'
    ).hasMatch(cnum);
  }

  bool validCVC(cvc) {
    if(cvc == "") return true;
    else {
      return RegExp(
        r'^(\d{3})$'
      ).hasMatch(cvc);
    }
  }
}

class PaiementStripeWebPage extends StatefulWidget {

  @override
  _PaiementStripeWebPageState createState() => _PaiementStripeWebPageState();
}

class _PaiementStripeWebPageState extends State<PaiementStripeWebPage> {
  Widget navSection = NavSection();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String msgError;

  @override
  void initState() {
    super.initState();
    impl.initStripe();
    msgError = "";
    //panier = [];
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paiement Stripe ',
      home: Scaffold(            
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black,
          ),                    
          title: navSection,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("Votre panier: ", style: Theme.of(context).textTheme.headline2),
                ),
                Column(
                  children: List.generate(
                    panier.length, 
                    (index) => Card(
                      child: Container(
                        //color: products[index].isActive() ? Colors.green : null,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text("Produit: ", style: TextStyle(fontSize: 20)),
                                    //Text(panier[index].subscriptionName, style: TextStyle(fontSize: 20)),
                                    Text(panier[index].dbName.value.toString())
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Prix: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                    //Text(panier[index].price.toString()),
                                    Text(panier[index].backupPrice.value.toString()),
                                    //Text(" euros")
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  //Text("base de données: "),
                                  //Text(panier[index].dbName)
                                  Text("hostname: "),
                                  Text(panier[index].hostname.value.toString())
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Text("Taille: "),
                                  //Text(panier[index].dbSize)
                                  Text(panier[index].dbSize.value.toString())
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                panier.removeAt(index);
                                print(panier);
                                setState(() {
                                  navSection = NavSection();
                                });
                                _formKey.currentState.save();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Text("Retirer du panier"),
                              ),
                              //child: Text(products[index].isActive() ? "Supprimer subscription": "Ajouter au panier"),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  return states.contains(MaterialState.disabled) ? null : Colors.white;
                                }),
                                backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                  return states.contains(MaterialState.disabled) ? null : Colors.red;
                                }),
                              ),
                            ),
                          ]
                        )
                      )
                    )
                  )
                ),
                SizedBox(height: 5),
                Text(msgError, style: TextStyle(color: Colors.red)),
                SizedBox(height: 5),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: TextButton(
                    onPressed: panier.length==0 ? null : () {
                      try {
                        impl.redirectToCheckout(panier);
                      }
                      catch(e) { //marche pas
                        print(e);
                        msgError = "il y a eu une erreur !!!!";
                        setState(() {
                          
                        });
                      }
                    },
                    child: Text("Payer"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : Colors.white;
                      }),
                      backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : cartesoftBlueLight3;
                      }),
                    )
                  ),
                ),
                //test gocardless !!!!!!!!!!!!!!!!!!!!!!!!!!!
                TextButton(
                  onPressed: () async {
                    await _authService.createRedirectFlowGoCL();
                  },
                  child: Text("gocardless")
                ),
              ]
            )
          )
        ),  
      )
    );
  }

  bool validExpMonth(exp) {
    if(RegExp(r'^(\d{2})$').hasMatch(exp)) {
      if(int.parse(exp) > 0 && int.parse(exp) <= 12) return true;
      else return false;
    }
    else return false;
    
  }

  bool validExpYear(exp) {
    return RegExp(
      r'^(\d{4})$'
    ).hasMatch(exp);
  }

  bool validCard(cnum) {
    cnum = cnum.replaceAll(" ", "");
    return RegExp(
      r'^(\d{16})$'
    ).hasMatch(cnum);
  }
}