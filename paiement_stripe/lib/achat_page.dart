import 'package:flutter/material.dart';
import 'package:paiement_stripe/nav_section.dart';
import 'package:paiement_stripe/services/auth_service.dart';
//import 'package:paiement_stripe/models/Product.dart';

class PageAchat extends StatefulWidget {
  @override
  _PageAchatState createState() => _PageAchatState();
}

class _PageAchatState extends State<PageAchat> {
  Widget navSection = NavSection();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if(isSmallScreen(context)) {
      return MaterialApp(
        title: "Page d'achat ",
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
            minimum: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Liste des produits: ", style: Theme.of(context).textTheme.headline4),
                  ),
                  Column(
                    children: List.generate(
                      products.length, 
                      (index) => Card(
                        child: Container(
                          color: products[index].isActive() ? Colors.green : null,
                          padding: EdgeInsets.all(10),
                          //padding: EdgeInsets.only(left:10, top:10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Produit: ", style: TextStyle(fontSize: 20)),
                                  Text(products[index].subscriptionName)
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Prix: ", style: TextStyle(fontSize: 20)),
                                  Text(products[index].price.toString()),
                                  Text(" euros")
                                ],
                              ),
                              Row(
                                children: [
                                  Text("base de données: ", style: TextStyle(fontSize: 20)),
                                  Text(products[index].dbName)
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Taille: ", style: TextStyle(fontSize: 20)),
                                  Text(products[index].dbSize)
                                ],
                              ),
                              /*TextButton(
                                onPressed: products[index].inPanier(panier) || products[index].isActive() ? null : () {
                                  //panier.add(new Item(products[index].dbID, products[index].priceID));
                                  panier.add(products[index]);
                                  setState(() {
                                    panier.contains(products[index]) || products[index].isActive();
                                    //navSection = NavSection();
                                  });
                                  _formKey.currentState.save();
                                },
                                child: Text("Ajouter au panier")
                              )*/
                            ]
                          )
                        ) 
                      )
                    )
                  ),
                ]
              )
            )
          ),  
        )
      );
    }
    else {
      return MaterialApp(
        title: "Page d'achat ",
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
                  child: Text("Liste des produits: ", style: Theme.of(context).textTheme.headline2),
                ),
                  Column(
                    children: List.generate(
                      products.length, 
                      (index) => Card(
                        child: Container(
                          color: products[index].isActive() ? Colors.green : null,
                          padding: EdgeInsets.all(10),
                          //padding: EdgeInsets.only(left:10, top:10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("Produit: ", style: TextStyle(fontSize: 20)),
                                      Text(products[index].subscriptionName, style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Prix: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(products[index].price.toString()),
                                      Text(" euros")
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Text("base de données: "),
                                    Text(products[index].dbName)
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Text("Taille: "),
                                    Text(products[index].dbSize)
                                  ],
                                ),
                              ),
                              /*TextButton(
                                onPressed: products[index].inPanier(panier) || products[index].isActive() ? null : () {
                                //onPressed: panier.contains(products[index]) || products[index].isActive() ? null : () {
                                  //panier.add(new Item(products[index].dbID, products[index].priceID));
                                  panier.add(products[index]);
                                  //faire s'actualiser dynamiquement le nombre d'objets dans le panier affiché dans la navBar !!!!
                                  //navSection.state();
                                  setState(() {
                                    panier.contains(products[index]) || products[index].isActive();
                                    navSection = NavSection();
                                  });
                                  _formKey.currentState.save();
                                },
                                child: Text("Ajouter au panier")
                                //child: Text(products[index].isActive() ? "Supprimer subscription": "Ajouter au panier"),
                                /*style: ButtonStyle(
                                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                    return states.contains(MaterialState.disabled) ? null : Colors.white;
                                  }),
                                  backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                    return products[index].isActive() ? Colors.red : Colors.green;
                                  }),
                                ),*/
                              )*/
                            ]
                          )
                        )
                      )
                    )
                  ),
                  /*TextButton(
                    onPressed: () {
                      impl.redirectToCheckout(panier);
                    },
                    child: Text("Payer")
                  )*/
                ]
              )
            )
          ),  
        )
      );
    }
  }
}