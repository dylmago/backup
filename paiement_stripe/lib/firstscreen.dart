import 'package:flutter/material.dart';
import 'package:paiement_stripe/models/Product.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/nav_section.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

/*class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/': (context) => Authentication(),
        '/home': (context) => FirstScreen(),
        '/profile': (context) => ProfilePage(),
        '/company': (context) => CompagnyCreatePage(),
        '/approbation': (context) => UserApprobationPage(),
        '/paiement': (context) => PaiementStripeWebPage(),
        '/companies': (context) => UserCompaniesPage(),
      },
    );
  }
}*/

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final _authService = AuthService();
  Widget navSection = NavSection();

  final BorderSide border = new BorderSide(color: cartesoftBlueDark, width: 3);

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) { //problème sur le web (il le fait 2 fois et ça marche pas)
    print(stopDefaultButtonEvent);
    if(stopDefaultButtonEvent) return false;
    print("BACK BUTTON!!!!!!!!!!!!!!!!"); // Do some stuff.
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accueil ',
      home: Scaffold(            
        appBar: AppBar(                       
          title: navSection,
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: [
            contentSection(context),
          ],
        )       
      )
    );
  }

  Widget contentSection(BuildContext context) {
    if(isLargeScreen(context) || isMediumScreen(context)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Wrap(
            spacing: 20,
            children: List.generate(
              invs.length,
              (index) => SizedBox(
                height: 300,
                width: 350,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: OutlinedButton(
                    onPressed: () async {
                      String svc = invs[index].type;
                      var res = await _authService.getInvSvc(invs[index].type);
                      if(res==0) {
                        final int length = panier.length;
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen(svc)));
                        if(length != panier.length) {
                          setState(() {
                            navSection = NavSection();
                          });
                        }
                        _authService.getInv();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 10),
                          child: Image.network(invs[index].logo, height: 100, width: 150),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 15, bottom: 5),
                          child: Text(invs[index].name),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 15),
                          child: Text(invs[index].count.toString()),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : Colors.black;
                      }),
                      /*overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : cartesoftBlueLight5;
                      }),*/
                      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.hovered) ? border : null;
                      }),
                    ),
                  )
                )
              ),
            )
          ),
        ),
      );
    }
    else {
      return Column(
        children: List.generate(
          invs.length,
          (index) => SizedBox(
            height: 200,
            width: double.infinity, //double.maxFinite, 
            child: Container(
              padding: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () async {
                  String svc = invs[index].type;
                  var res = await _authService.getInvSvc(invs[index].type);
                  if(res==0) {
                    final int length = panier.length;
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen(svc)));
                    if(length != panier.length) {
                      setState(() {
                        navSection = NavSection();
                      });
                    }
                    _authService.getInv();
                  }
                },
                child: Column(
                  children: [
                    if(invs[index].logo != null) Image.network(invs[index].logo, height: 50, width: 100),
                    Text(invs[index].name),
                    Text(invs[index].count.toString()),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.black;
                  }),
                ),
              ),
            ),
          )
        ),
      );
    }
  }
}

class SecondScreen extends StatefulWidget {
  final String service;

  SecondScreen(this.service);

  @override
  _SecondScreenState createState() => _SecondScreenState(service);
}

class _SecondScreenState extends State<SecondScreen> {
  Widget navSection = NavSection();
  final _authService = AuthService();
  String service;

  _SecondScreenState(this.service);

  @override
  Widget build(BuildContext context) {
    return Scaffold(            
      appBar: AppBar(     
        leading: BackButton(
          onPressed: () async {
            //await _authService.getInv();
            Navigator.of(context).pop();
          },
        ),                  
        iconTheme: IconThemeData(color: Colors.black),                
        title: navSection,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          contentSection(context),
        ],
      )       
    );
  }

  Widget contentSection(BuildContext context) {
    if(isLargeScreen(context) || isMediumScreen(context)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Wrap(
            spacing: 20,
            children: List.generate(
              invs.length,
              (index) => SizedBox(
                height: 300,
                width: 350,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: OutlinedButton(
                    onPressed: () async {
                      String type = invs[index].type;
                      //var res = await _authService.getInvSvcType(service , invs[index].type);
                      var res = await _authService.getInvSvcType(invs[index].type , invs[index].subType);
                      if(res==0) {
                        final int length = panier.length;
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdScreen(service, type)));
                        if(length != panier.length) {
                          setState(() {
                            navSection = NavSection();
                          });
                        }
                        _authService.getInvSvc(service);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(invs[index].logo != null) 
                          Container(
                            alignment: Alignment.topLeft,
                            child: Image.network(invs[index].logo, height: 100, width: 150),
                          ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 15, bottom: 5, top: 10),
                          child: Text(invs[index].name),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 15),
                          child: Text(invs[index].count.toString()),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : Colors.black;
                      }),
                      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.hovered) ? BorderSide(color: cartesoftBlueDark, width: 3) : null;
                      }),
                    ),
                  )
                )
              ),
            )
          ),
        ),
      );
      
    }
    else {
      return Column(
        children: List.generate(
          invs.length,
          (index) => SizedBox(
            height: 200,
            width: double.infinity, //double.maxFinite, 
            child: Container(
              padding: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () async {
                  String type = invs[index].type;
                  //var res = await _authService.getInvSvcType(service , invs[index].type);
                  print("test");
                  print(invs[index].type);
                  print(invs[index].subType);
                  var res = await _authService.getInvSvcType(invs[index].type , invs[index].subType);
                  if(res==0) {
                    final int length = panier.length;
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdScreen(service, type)));
                    if(length != panier.length) {
                      setState(() {
                        navSection = NavSection();
                      });
                    }
                    _authService.getInvSvc(service);
                  }
                },
                child: Column(
                  children: [
                    if(invs[index].logo != null) Image.network(invs[index].logo, height: 50, width: 100),
                    Text(invs[index].name),
                    Text(invs[index].count.toString()),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.black;
                  }),
                ),
              ),
            ),
          )
        ),
      );
    }
  }
}

class ThirdScreen extends StatefulWidget {
  final String service;
  final String type;

  ThirdScreen(this.service, this.type);

  @override
  _ThirdScreenState createState() => _ThirdScreenState(service, type);
}

class _ThirdScreenState extends State<ThirdScreen> {
  Widget navSection = NavSection();
  final _authService = AuthService();
  String service;
  String type;

  _ThirdScreenState(this.service, this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(            
      appBar: AppBar( 
        leading: BackButton(
          onPressed: () async {
            //await _authService.getInvSvc(service);
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ), 
        title: navSection,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          contentSection(context),
        ],
      )       
    );
  }

  Widget contentSection(BuildContext context) {
    if(isLargeScreen(context) || isMediumScreen(context)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Wrap(
            spacing: 20,
            children: List.generate(
              invs.length,
              (index) => SizedBox(
                height: 300,
                width: 350,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: OutlinedButton(
                    onPressed: () async {
                      print("test");
                      print(invs[index].type);
                      print(invs[index].subType);
                      print(invs[index].version);
                      await _authService.getInvSvcTypeVersion(invs[index].type , invs[index].subType, invs[index].version);
                      final int length = panier.length;
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => LastScreen(service, type)));
                      if(length != panier.length) {
                        setState(() {
                          navSection = NavSection();
                        });
                      }
                      _authService.getInvSvcType(service , type);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(invs[index].logo != null) 
                          Container(
                            //alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 10),
                            child: Image.network(invs[index].logo, height: 100, width: 150),
                          ),
                        Text("Version: " + invs[index].name),
                        Text("Number: " + invs[index].count.toString()),
                      ],
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : Colors.black;
                      }),
                      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.hovered) ? BorderSide(color: cartesoftBlueDark, width: 3) : null;
                      }),
                    ),
                  )
                )
              ),
            )
          ),
        ),
      ); 
    }
    else {
      return Column(
        children: List.generate(
          invs.length,
          (index) => SizedBox(
            height: 200,
            width: double.infinity, //double.maxFinite, 
            child: Container(
              padding: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () async {
                  print("test");
                  print(invs[index].type);
                  print(invs[index].subType);
                  print(invs[index].version);
                  await _authService.getInvSvcTypeVersion(invs[index].type , invs[index].subType, invs[index].version);
                  //await _authService.getInvSvcTypeVersion(service , type, invs[index].type);
                  final int length = panier.length;
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => LastScreen(service, type)));
                  if(length != panier.length) {
                    setState(() {
                      navSection = NavSection();
                    });
                  }
                  _authService.getInvSvcType(service , type);
                },
                child: Column(
                  children: [
                    if(invs[index].logo != null) Image.network(invs[index].logo, height: 50, width: 100),
                    Text("Version: " + invs[index].name),
                    Text("Number: " + invs[index].count.toString()),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.black;
                  }),
                ),
              ),
            ),
          )
        ),
      );
    }
  }
}

class LastScreen extends StatefulWidget {
  final String service;
  final String type;

  LastScreen(this.service, this.type);

  @override
  _LastScreenState createState() => _LastScreenState(service, type);
}

class _LastScreenState extends State<LastScreen> {
  Widget navSection = NavSection();
  final _authService = AuthService();
  String service;
  String type;

  _LastScreenState(this.service, this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(            
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
      body: ListView(
        children: [
          contentSection(),
        ],
      )       
    );
  }

  Widget contentSection() {
    if(isLargeScreen(context) || isMediumScreen(context)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Wrap(
            spacing: 20,
            children: List.generate(
              prods.length,
              (index) => SizedBox(
                height: 300,
                width: 350,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: OutlinedButton(
                    onPressed: () async {
                      Prod prod = await _authService.getInfoObj(prods[index].dbID, service);//await _authService.getInfoObj(prods[index].dbID, prods[index].type);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InfoScreen(prod)));
                      //_authService.getInvSvcTypeVersion(service , type, prods[index].type);
                    },
                    child: getInfos(index),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.disabled) ? null : Colors.black;
                      }),
                      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        return states.contains(MaterialState.hovered) ? BorderSide(color: cartesoftBlueDark, width: 3) : null;
                      }),
                    ),
                  )
                )
              ),
            )
          ),
        ),
      ); 
    }
    else {
      return Column(
        children: List.generate(
          prods.length,
          (index) => SizedBox(
            height: 300,
            width: double.infinity, //double.maxFinite, 
            child: Container(
              padding: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () async {
                  Prod prod = await _authService.getInfoObj(prods[index].dbID, prods[index].type);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InfoScreen(prod)));
                },
                child: Container(
                  //alignment: Alignment.bottomLeft,
                  child: getInfos(index),
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.black;
                  }),
                ),
              ),
            ),
          )
        ),
      );
    }
  }

  Widget getInfos(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(prods[index].logo != null) 
          Container(
            //alignment: Alignment.topLeft,
            padding: EdgeInsets.only(bottom: 10),
            child: Image.network(prods[index].logo, height: 100, width: 150),
          ),
        if(prods[index].version.visible == 1) Text(prods[index].version.label + ": " + prods[index].version.value.toString(), style: TextStyle(color: couleurs[prods[index].version.colour -1])),
        if(prods[index].dbName != null && prods[index].dbName.visible == 1) Text(prods[index].dbName.label + ": " + prods[index].dbName.value.toString(), style: TextStyle(color: couleurs[prods[index].dbName.colour -1])),
        if(prods[index].hostname.visible == 1) Text(prods[index].hostname.label + ": " + prods[index].hostname.value.toString(), style: TextStyle(color: couleurs[prods[index].hostname.colour -1])),
        if(prods[index].dbName != null && prods[index].dbSize.visible == 1) Text(prods[index].dbSize.label + ": " + prods[index].dbSize.value.toString(), style: TextStyle(color: couleurs[prods[index].dbSize.colour -1])),
        if(prods[index].dbName != null && prods[index].backupPrice.visible == 1) Text(prods[index].backupPrice.label + ": " + prods[index].backupPrice.value.toString(), style: TextStyle(color: couleurs[prods[index].backupPrice.colour -1])),
        if(prods[index].dbName != null && prods[index].backupStatus.visible == 1) Text(prods[index].backupStatus.label + ": " + prods[index].backupStatus.value.toString(), style: TextStyle(color: couleurs[prods[index].backupStatus.colour -1])),
        if(prods[index].dbName != null && prods[index].backupAcivated.visible == 1) Text(prods[index].backupAcivated.label + ": " + prods[index].backupAcivated.value.toString(), style: TextStyle(color: couleurs[prods[index].backupAcivated.colour -1])),
        SizedBox(height: 10),
        if(prods[index].dbName != null)
          TextButton(
            onPressed: prods[index].inPanier(panier) ? null : () {
              if(prods[index].backupAcivated.value == "false") { //faire un backup
                panier.add(prods[index]);
                setState(() {
                  //panier.contains(prods[index]) || products[index].isActive();
                  navSection = NavSection();
                });
              }
              else { //supprimer un backup existant
                print("suppression backup");
                //à gérer !!!
                //manière imaginée: utiliser la même api que pour le paiement, mais n'envoyé qu'un item avec le champ add à false
                _authService.deleteSubscription(prods[index].dbID);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(5),
              child: prods[index].backupAcivated.value == "false" ? Text("Faire un backup") : Text("Supprimer backup"),
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.white;
              }),
              backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                if(prods[index].backupAcivated.value == "false") return states.contains(MaterialState.disabled) ? Colors.green[100] : green;
                else return states.contains(MaterialState.disabled) ? null : red;
              }),
            )
          ),
      ],
    );
  }
}

//--------------------écran avec les différents onglets permettant de voir différentes infos---------------------------------
class InfoScreen extends StatefulWidget {
  final Prod prod;

  InfoScreen(this.prod);

  @override
  _InfoScreenState createState() => _InfoScreenState(prod);
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin{
  Widget navSection = NavSection();
  Prod produit;
  TabController _tabController;

  _InfoScreenState(this.produit);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accueil ',
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
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud_outlined, color: cartesoftBlueLight1),
              ),
              Tab(
                icon: Icon(Icons.beach_access_sharp, color: cartesoftBlueLight1),
              ),
              Tab(
                icon: Icon(Icons.brightness_5_sharp, color: cartesoftBlueLight1),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Column(
              children: [
                if(produit.logo != null)
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Image.network(produit.logo, height: 100, width: 150),
                  ),
                if(produit.port.visible == 1) Text(produit.port.label + ": " + produit.port.value.toString(), style: TextStyle(color: couleurs[produit.port.colour -1])),
                if(produit.state.visible == 1) Text(produit.state.label + ": " + produit.state.value.toString(), style: TextStyle(color: couleurs[produit.state.colour -1])),
                if(produit.datadir.visible == 1) Text(produit.datadir.label + ": " + produit.datadir.value.toString(), style: TextStyle(color: couleurs[produit.datadir.colour -1])),
                if(produit.dbList.visible == 1) Text(produit.dbList.label + ": " + produit.dbList.value.toString(), style: TextStyle(color: couleurs[produit.dbList.colour -1])),
                //Text(produit.dbList.value[0]),
                if(produit.edition.visible == 1) Text(produit.edition.label + ": " + produit.edition.value.toString(), style: TextStyle(color: couleurs[produit.edition.colour -1])),
                if(produit.version.visible == 1) Text(produit.version.label + ": " + produit.version.value.toString(), style: TextStyle(color: couleurs[produit.version.colour -1])),
                if(produit.dbName.visible == 1) Text(produit.dbName.label + ": " + produit.dbName.value.toString(), style: TextStyle(color: couleurs[produit.dbName.colour -1])),
                if(produit.hostname.visible == 1) Text(produit.hostname.label + ": " + produit.hostname.value.toString(), style: TextStyle(color: couleurs[produit.hostname.colour -1])),
                if(produit.startupTime.visible == 1) Text(produit.startupTime.label + ": " + produit.startupTime.value.toString(), style: TextStyle(color: couleurs[produit.startupTime.colour -1])),
                if(produit.dbSize.visible == 1) Text(produit.dbSize.label + ": " + produit.dbSize.value.toString(), style: TextStyle(color: couleurs[produit.dbSize.colour -1])),
                if(produit.dbRole.visible == 1) Text(produit.dbRole.label + ": " + produit.dbRole.value.toString(), style: TextStyle(color: couleurs[produit.dbRole.colour -1])),
                if(produit.backupPrice.visible == 1) Text(produit.backupPrice.label + ": " + produit.backupPrice.value.toString(), style: TextStyle(color: couleurs[produit.backupPrice.colour -1])),
                if(produit.backupStatus.visible == 1) Text(produit.backupStatus.label + ": " + produit.backupStatus.value.toString(), style: TextStyle(color: couleurs[produit.backupStatus.colour -1])),
                if(produit.backupAcivated.visible == 1) Text(produit.backupAcivated.label + ": " + produit.backupAcivated.value.toString(), style: TextStyle(color: couleurs[produit.backupAcivated.colour -1])),
              ],
            ),
            Center(
              child: Text('It\'s rainy here'),
            ),
            Center(
              child: Text('It\'s sunny here'),
            ),
          ],
        ),
      )       
    );
  }
}