import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:paiement_stripe/achat_page.dart';
import 'package:paiement_stripe/approbation.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/compagny_page.dart';
import 'package:paiement_stripe/firstscreen.dart';
import 'package:paiement_stripe/main.dart';
import 'package:paiement_stripe/paiement_stripe.dart';
import 'package:paiement_stripe/profile_page.dart';
import 'package:paiement_stripe/user_companies.dart';

class NavSection extends StatefulWidget {
  @override
  _NavSectionState createState() => _NavSectionState();

}

class _NavSectionState extends State<NavSection> {
  final _authService = AuthService();
  List<String> items;

  @override
  void initState() {
    super.initState();
    if(status.admin) {
      if(status.owner) items = ['', 'Home', 'Contact', 'Profile', 'Companies', 'My Company', 'Approbation', 'Sign out'];
      else items = ['', 'Home', 'Contact', 'Profile', 'Companies', 'Approbation', 'Sign out'];
    }
    else items = ['', 'Home', 'Contact', 'Profile', 'Companies', 'Sign out'];
    items.add('Produits');
    items.add('Panier');
    //if(panier.length != 0) items.add('Panier');
  } 

  @override
  Widget build(BuildContext context) {
    if(isLargeScreen(context) || isMediumScreen(context)) {
      return Container(
        child: Row(
          children: [
            Image(image: AssetImage("Cartesoft.png"), height: 150, width: 150,),
            Expanded(
              child: Text('')
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () async {
                  //Navigator.of(context).pushNamed('home');
                  await _authService.getInv();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FirstScreen()));
                },
                child: Row(
                  children: [
                    Text('Home', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.home, color: cartesoftBlue)
                    )
                  ],
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: Row(
                  children: [
                    Text('Contact', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.phone, color: cartesoftBlue)
                    )
                  ],
                )
              ),
            ),
            profileDropDown(),
            companyWidget(),
            approbationWidget(),
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextButton(
                onPressed: () async {
                  await _authService.getAgents();
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => PaiementStripeWebPage()));
                },
                child: Text('Agents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextButton(
                onPressed: () async {
                  await _authService.getProducts();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PageAchat()));
                },
                child: Text('Produits', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
              ),
            ),
            //page de paiement Stripe
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextButton(
                onPressed: () {
                  //Navigator.of(context).pushNamed('paiement');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaiementStripeWebPage()));
                },
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.shopping_basket, color: cartesoftBlue),
                    ),
                    SizedBox(
                      width: 30,
                      height: 20,
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        //color: Colors.yellow[700],
                        color: cartesoftOrangeLight2,
                        child: Text(panier.length.toString(), style: TextStyle(color: Colors.white),)
                      )
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Container(
        child: Row(
          children: [
            //Image(image: AssetImage("Cartesoft.png"), height: 100, width: 100,), //l'image est bug sur mobileS
            /*Expanded(
              child: Text('')
            ),*/
            dropdownMenu(),
          ],
        ),
      );
    }
  }

  Widget profileDropDown() {
    return SizedBox(
      width: 100,
      child: DropdownButtonFormField<String>(
        value: 'Profile',
        icon: Icon(Icons.arrow_drop_down),
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
        decoration: InputDecoration.collapsed(hintText: ''),
        onChanged: (String newValue) {
          redirect(newValue);
        },
        items: <String>['Profile', 'Companies', 'Sign out']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: cartesoftBlue))
          );
        }).toList(),
      )
    );
  }

  Widget approbationWidget() {
    if(status.admin | status.owner) { //isAdmin
      return Padding(
        padding: EdgeInsets.all(6),
        child: TextButton(
          onPressed: () async {
            await _authService.getCompUsers();
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserApprobationPage()));
            //Navigator.pushNamed(context, 'approbation');
          },
          child: Text("Approbation", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
        )
      );
      
    }
    else {
      return Text('');
    }
  }

  Widget companyWidget() {
    if(status.owner || status.admin) { //pas certain que l'admin ai le droit !!!!!
      return Padding(
        padding: EdgeInsets.all(6),
        child: TextButton(
          onPressed: () async {
            await _authService.getCompany();
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompagnyCreatePage()));
            //Navigator.of(context).pushNamed('company');
          },
          child: Text("My Company", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cartesoftBlue)),
        )
      );
    }
    else {
      return Text('');
    }
  }

  Widget dropdownMenu() {
    return Flexible(
      child: DropdownButtonFormField<String>(
        value: '',
        icon: Icon(Icons.reorder),
        style: TextStyle(color: Colors.blue),
        decoration: InputDecoration.collapsed(hintText: ''),
        onChanged: (String newValue) {
          redirect(newValue);
        },
        items: items
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: cartesoftBlue)),
          );
        }).toList(),
      )
    ); 
  }

  redirect(String value) async{
    if(value == 'Home') {
      await _authService.getInv();
      Navigator.push(context, MaterialPageRoute(builder: (context) => FirstScreen()));
    }
    else if(value == 'Sign out') {
      _authService.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => Authentication()));
    }
    else if(value == 'Approbation') {
      await _authService.getCompUsers();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserApprobationPage()));
      //Navigator.pushNamed(context, 'approbation');
    } 
    else if(value == 'Profile') {
      await _authService.getSalutations();
      await _authService.getCallMethods();
      await _authService.getInfos();
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
      //Navigator.of(context).pushNamed('profile');
    }
    else if(value == 'My Company') {
      await _authService.getCompany();
      Navigator.push(context, MaterialPageRoute(builder: (context) => CompagnyCreatePage()));
      //Navigator.of(context).pushNamed('company');
    }
    else if(value == 'Companies') {
      await _authService.getUserAssoc();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserCompaniesPage()));
      //Navigator.of(context).pushNamed('companies');
    }
    else if(value == 'Panier') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PaiementStripeMobilePage()));
    }
    else if(value == 'Produits') {
      await _authService.getProducts();
      Navigator.push(context, MaterialPageRoute(builder: (context) => PageAchat()));
    }
  }
}

HexColor black = HexColor("#000000");
HexColor green = HexColor("#008000");
HexColor red = HexColor("#FF0000");

HexColor cartesoftBlue = HexColor("#006fb4");
HexColor cartesoftBlueLight1 = HexColor("#0080c8");
HexColor cartesoftBlueLight2 = HexColor("#0092dc");
HexColor cartesoftBlueLight3 = HexColor("#00a0eb");
HexColor cartesoftBlueLight4 = HexColor("#26aeee");
HexColor cartesoftBlueLight5 = HexColor("#4cbcf1");
HexColor cartesoftBlueDark = HexColor("#004f92");

HexColor cartesoftOrange = HexColor("#f36612");
HexColor cartesoftOrangeLight1 = HexColor("#f47a3b");
HexColor cartesoftOrangeLight2 = HexColor("#f9af8e");
HexColor cartesoftOrangeLight3 = HexColor("#f9af8e");
HexColor cartesoftOrangeLight4 = HexColor("#fbceba");

HexColor cartesoftOrangeDark1 = HexColor("#e8600d");
HexColor cartesoftOrangeDark2 = HexColor("#da5908");
HexColor cartesoftOrangeDark3 = HexColor("#cd5205");
HexColor cartesoftOrangeDark4 = HexColor("#b44500");

HexColor mauve = HexColor("#800080");

List<HexColor> couleurs = [
  black,
  green,
  red,
  cartesoftBlue,
  cartesoftBlueLight5,
  cartesoftBlueLight4,
  cartesoftBlueLight3,
  cartesoftBlueLight2,
  cartesoftBlueLight1,
  cartesoftBlueDark,
  cartesoftOrange,
  cartesoftOrangeLight4,
  cartesoftOrangeLight3,
  cartesoftOrangeLight2,
  cartesoftOrangeLight1,
  cartesoftOrangeDark1,
  cartesoftOrangeDark2,
  cartesoftOrangeDark3,
  cartesoftOrangeDark4,
  mauve
];


bool isLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 1200;
}
//Small screen is any screen whose width is less than 800 pixels
bool isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.width < 800;
}
//Medium screen is any screen whose width is less than 1200 pixels and more than 800 pixels
bool isMediumScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > 800 && MediaQuery.of(context).size.width < 1200;
} 