import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:paiement_stripe/main.dart';
import 'package:paiement_stripe/models/Company.dart';
import 'package:paiement_stripe/nav_section.dart';

class CompagnyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => CompanyPage(),
        '/choose': (context) => CompagnyChoosePage(),
        '/create': (context) => CompagnyCreatePage()
      },
    );
  }
}

class CompanyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              "Vous devez vous associer à une compagnie",
              style: Theme.of(context).textTheme.headline3
            )
          ),   
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: TextButton(
                    onPressed: () { //rediriger vers la page permettant de s'associer à une compagnie 
                      Navigator.of(context).pushNamed('/choose');
                    }, 
                    child: Text("S'associer à une compagnie")
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: TextButton(
                    onPressed: () { //rediriger vers la page permettant de créer une compagnie
                      Navigator.of(context).pushNamed('/create');
                    }, 
                    child: Text("Créer une compagnie")
                  )
                )
              ],
            )  
          ) 
        ],
      ) 
    );
  }
}

//----------------choix d'une compagnie existante--------------------------------------------------------
class CompagnyChoosePage extends StatefulWidget {
  @override
  _CompagnyChoosePageState createState() => _CompagnyChoosePageState();
}

class _CompagnyChoosePageState extends State<CompagnyChoosePage> {
  final _uuidControler = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            child: Text("Choix d'une compagnie", style: Theme.of(context).textTheme.headline2),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _uuidControler,
                  decoration: InputDecoration(labelText: "UUID compagnie"),
                ),
                SizedBox(height:10),
                TextButton(
                  onPressed: () async {
                    print(status.stat);
                    await _authService.associateUser(_uuidControler.text.trim());
                    print(status.stat);
                    await _authService.getStatus();
                    print(status.stat);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RouterPage()));
                  }, 
                  child: Text("Valider"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled) ? null : Colors.white;
                    }),
                    backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled) ? null : Colors.blue;
                    }),
                  ),
                )
              ],
            )
          )
        ],
      )   
    );
  }
}

//------------création d'une nouvelle compagnie-----------------------------------------------------------------------------------
class CompagnyCreatePage extends StatefulWidget {
  @override
  _CompagnyCreatePageState createState() => _CompagnyCreatePageState();
}

class _CompagnyCreatePageState extends State<CompagnyCreatePage> {
  final _formKey = GlobalKey<FormState>();
  Widget navSection;
  final _authService = AuthService();
  String title;
  var _companyNameController;
  var _tvaController;
  var _webSiteController;
  var _mobileController;
  var _faxController = TextEditingController();
  var _compGAddController;
  var _compGCityController;
  var _compGCPController;
  var _compGMailController;
  var _compIAddController;
  var _compICityController;
  var _compICPController;
  var _compIMailController;

  String compGCountry;
  String compICountry;
  String codeM;
  String codeF = 'BE';

  bool numValid = false;
  bool numFixValid = true;
  bool tvaValid = false;

  @override
  void initState() {
    super.initState();
    if(company == null) {
      title = "Création d'une compagnie";
      _companyNameController = TextEditingController();
      _tvaController = TextEditingController();
      _webSiteController = TextEditingController();
      _mobileController = TextEditingController();
      _compGAddController = TextEditingController();
      _compGCityController = TextEditingController();
      _compGCPController = TextEditingController();
      _compGMailController = TextEditingController();
      _compIAddController = TextEditingController();
      _compICityController = TextEditingController();
      _compICPController = TextEditingController();
      _compIMailController = TextEditingController();
      compGCountry = "Belgique";
      compICountry = "Belgique";
      codeM = 'BE';
    }
    else {
      title = "Company Profile";
      _companyNameController = TextEditingController(text: company.name);
      _tvaController = TextEditingController(text: company.tvaNum);
      _webSiteController = TextEditingController(text: company.website);
      _compGAddController = TextEditingController(text: company.generalAdr.adresse);
      _compGCityController = TextEditingController(text: company.generalAdr.city);
      _compGCPController = TextEditingController(text: company.generalAdr.codeP);
      _compGMailController = TextEditingController(text: company.generalEmail);
      _compIAddController = TextEditingController(text: company.invoiceAdr.adresse);
      _compICityController = TextEditingController(text: company.invoiceAdr.city);
      _compICPController = TextEditingController(text: company.invoiceAdr.codeP);
      _compIMailController = TextEditingController(text: company.invoiceEmail);
      compGCountry = company.generalAdr.country;
      compICountry = company.invoiceAdr.country;
      _mobileController = TextEditingController(text: company.phoneNum['local_format']);
      if(company.faxNum != null) {
        _faxController = TextEditingController(text: company.faxNum['local_format']);
        codeF = company.faxNum['country_code'];
      }
      codeM = company.phoneNum['country_code'];
      navSection = new NavSection();
    }
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
      ],
      home: page()
    );
  }

  Widget page() {
    if(company == null) {
      return Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: _companyForm(),
            ),
          )
        ),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          iconTheme: IconThemeData(color: Colors.black),                
          title: navSection,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: _companyForm(),
            ),
          )
        ),
      );
    }
  }

  Widget _companyForm() {
    if(isSmallScreen(context)) {
      return Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(10),
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
          companyInput(),
          tvaInput(),
          companyWebSite(),
          phoneNumberInput(),
          faxNumberInput(),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Company General Address", style: Theme.of(context).textTheme.headline6),
          ),
          companyGeneralAddress(),
          companyGeneralCity(),
          companyGeneralCP(),
          paysGDropdown(),
          SizedBox(height: 5),
          companyGeneralMail(),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Company Invoice Address", style: Theme.of(context).textTheme.headline6),
          ),
          //autoFill
          if(company == null)
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: _autoFillInvoice,
                child: Text("Complete with company general address")
              )
            ),
          //
          companyInvoiceAddress(),
          companyInvoiceCity(),
          companyInvoiceCP(),
          paysIDropdown(),
          SizedBox(height: 5),
          companyInvoiceMail(),
          SizedBox(height: 20),
          SizedBox(
            height: 40,
            width: 100,
            child: buttonValidate(),
          )
        ],
      );
    }
    else {
      return Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(10),
            child: Text(title, style: Theme.of(context).textTheme.headline2),
          ),
          Row(
            children: [
              Flexible(child: companyInput()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: tvaInput()
                )
              )
            ],
          ),
          companyWebSite(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: phoneNumberInput()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: faxNumberInput(),
                )
              )
            ],
          ),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Company General Address", style: Theme.of(context).textTheme.headline4),
          ),
          Row(
            children: [
              Flexible(child: companyGeneralAddress()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: companyGeneralCity(),
                )
              )
            ],
          ),
          Row(
            children: [
              Flexible(child: companyGeneralCP()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: paysGDropdown(),
                )
              )
            ],
          ),
          SizedBox(height: 10),
          companyGeneralMail(),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Company Invoice Address", style: Theme.of(context).textTheme.headline4),
          ),
          //autoFill
          if(company == null)
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: _autoFillInvoice,
                child: Text("Complete with company general address")
              )
            ),
          //
          Row(
            children: [
              Flexible(child: companyInvoiceAddress()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: companyInvoiceCity(),
                )
              )
            ],
          ),
          Row(
            children: [
              Flexible(child: companyInvoiceCP()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: paysIDropdown(),
                )
              )
            ],
          ),
          SizedBox(height: 5),
          companyInvoiceMail(),
          SizedBox(height: 20),
          SizedBox(
            height: 40,
            width: 100,
            child: buttonValidate(),
          )
        ]
      );
    }
  }

  _autoFillInvoice() {
    _compIAddController.text = _compGAddController.text;
    _compICityController.text = _compGCityController.text;
    _compICPController.text = _compGCPController.text;
    _compIAddController.text = _compGAddController.text;
    compICountry = compGCountry;
    _compIMailController.text = _compGMailController.text;
    setState(() {});
    _formKey.currentState.save();
  }

  validateCompany(var mobile, var fax) {
    final name = _companyNameController.text.trim();
    final tva = _tvaController.text.trim();
    final web = _webSiteController.text.trim();
    final addG = new Adresse(_compGAddController.text.trim(), _compGCityController.text.trim(), _compGCPController.text.trim(), compGCountry);
    final mailG = _compGMailController.text.trim();
    final addI = new Adresse(_compIAddController.text.trim(), _compICityController.text.trim(), _compICPController.text.trim(), compICountry);
    final mailI = _compIMailController.text.trim();
    Company company = new Company(name, tva, web, addG, mailG, addI, mailI, mobile, fax);
     _authService.postCompany(company);
  }

  Widget buttonValidate() {
    return TextButton(
      onPressed: () async {
        var mobile;
        if(_mobileController.text.isNotEmpty) {
          mobile = await validateMobile(_mobileController.text.trim(), codeM);
          numValid = jsonDecode(mobile)["valid"];
        }
        var fax;
        if(_faxController.text.isNotEmpty) {
          fax = await validateMobile(_faxController.text.trim(), codeF);
          numFixValid = jsonDecode(fax)["valid"];
        }
        if(_tvaController.text.isNotEmpty) tvaValid = await validateTVA(_tvaController.text.trim());
        _formKey.currentState.save();
        if(_formKey.currentState.validate()) {
          print(status.stat);
          await validateCompany(mobile, fax);
          print(status.stat);
          await _authService.getStatus();
          print(status.stat);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RouterPage()));
        } 
      },
      child: Text('Valider', style: TextStyle(fontSize: 17)),
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.disabled) ? null : Colors.white;
        }),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.disabled) ? null : cartesoftBlueLight3;
        }),
      ),
    );
  }

  Widget companyInput() {
    return TextFormField(
      controller: _companyNameController,
      decoration: InputDecoration(icon: Icon(Icons.home), labelText: 'Company name'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget tvaInput() { //http://apilayer.net/api/validate?c8808187dc6672c7d41f06931f648c5c
    return TextFormField(
      controller: _tvaController,
      decoration: InputDecoration(icon: Icon(Icons.account_balance), labelText: 'TVA Number'),
      validator: (value) {
        if(value.isEmpty) {
          return 'Please enter some text';
        }
        if(!tvaValid) {
          return 'Please enter a correct tva number';
        }
        return null;
      },
    );
  }

  Widget companyWebSite() {
    return TextFormField(
      controller: _webSiteController,
      decoration: InputDecoration(icon: Icon(Icons.web), labelText: 'Company Website'),
      /*validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },*/
    );
  }

  Widget phoneNumberInput() {
    return Row(
      children: [
        CountryCodePicker(
          initialSelection: codeM,
          favorite: ['+32'],
          onChanged: (countryCode) {
            codeM = countryCode.code;
          },
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'Company Phone Number',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                if(!numValid) {
                  return 'Please enter a correct number';
                }
                return null;
              },
            ),
          )
        )
      ],
    );
  }

  Widget faxNumberInput() {
    return Row(
      children: [
        CountryCodePicker(
          initialSelection: codeF,
          favorite: ['+32'],
          onChanged: (countryCode) {
            codeF = countryCode.code;
          },
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              controller: _faxController,
              decoration: InputDecoration(
                labelText: 'Company Fax Number',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                /*if (value.isEmpty) {
                  return 'Please enter some text';
                }*/
                if(!numFixValid) {
                  return 'Please enter a correct number';
                }
                return null;
              },
            ),
          )
          
        )
      ],
    );
  }

  Widget companyGeneralAddress() {
    return TextFormField(
      controller: _compGAddController,
      decoration: InputDecoration(icon: Icon(Icons.home), labelText: 'Company General Address'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
  Widget companyInvoiceAddress() {
    return TextFormField(
      controller: _compIAddController,
      decoration: InputDecoration(icon: Icon(Icons.home), labelText: 'Company Invoice Address'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget companyGeneralCity() {
    return TextFormField(
      controller: _compGCityController,
      decoration: InputDecoration(icon: Icon(Icons.location_city), labelText: 'Company General City'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
  Widget companyInvoiceCity() {
    return TextFormField(
      controller: _compICityController,
      decoration: InputDecoration(icon: Icon(Icons.location_city), labelText: 'Company Invoice City'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget companyGeneralCP() {
    return TextFormField(
      controller: _compGCPController,
      decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Company General Postal Code'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        if(!validCP(value)) {
           return 'Enter a correct postal code';
        }
        return null;
      },
    );
  }
  Widget companyInvoiceCP() {
    return TextFormField(
      controller: _compICPController,
      decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Company Invoice Postal Code'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        if(!validCP(value)) {
           return 'Enter a correct postal code';
        }
        return null;
      },
    );
  }

  Widget companyGeneralMail() {
    return TextFormField(
      controller: _compGMailController,
      decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Company General Email Address'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        if(!mailValid(value)) {
          return 'Enter a correct email';
        }
        return null;
      },
    );
  }
  Widget companyInvoiceMail() {
    return TextFormField(
      controller: _compIMailController,
      decoration: InputDecoration(icon: Icon(Icons.mail), labelText: 'Company Invoice Email Address'),
      validator: (value) {
        /*if (value.isEmpty) {
          return 'Please enter some text';
        }*/
        if(!mailValid(value)) {
          return 'Enter a correct email';
        }
        return null;
      },
    );
  }

  Widget paysGDropdown() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Country "), //mettre du style au texte (+ grand)
        ),
        CountryCodePicker(
          initialSelection: compGCountry,
          favorite: ['+32'],
          showCountryOnly: true,
          showFlagMain: false,
          showOnlyCountryWhenClosed: true,
          showDropDownButton: true,
          onChanged: (countryCode) {
            compGCountry = countryCode.code;
          },
          textStyle: TextStyle(color: cartesoftBlueLight2),
        ),
      ],
    );
  }

  Widget paysIDropdown() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Country "),
        ),
        CountryCodePicker(
          initialSelection: compICountry,
          favorite: ['+32'],
          showCountryOnly: true,
          showFlagMain: false,
          showOnlyCountryWhenClosed: true,
          showDropDownButton: true,
          onChanged: (countryCode) {
            compICountry = countryCode.code;
          },
          textStyle: TextStyle(color: cartesoftBlueLight2),
        ),
        /*DropdownButton<String>(
          value: compICountry,
          elevation: 16,
          style: TextStyle(color: cartesoftBlueLight2),
          underline: Container(
            height: 2,
            color: cartesoftBlueLight1,
          ),
          onChanged: (String newValue) {
            setState(() {
              compICountry = newValue;
            });
          },
          items: <String>['Belgique', 'Luxembourg', 'France', 'BE']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),*/
      ],
    );
  }

  Future<dynamic> validateMobile(String value, String code) async {
    var url = "http://apilayer.net/api/validate?access_key=235faa57fbf72659bde728b6ed5132c7&number='$value'&country_code=$code";
    try {
      var response = await http.get(url);
      return response.body;
    }
    catch (e) {
      print(e);
    }
  }

  Future<bool> validateTVA(String value) async {
    var url = "http://apilayer.net/api/validate?access_key=c8808187dc6672c7d41f06931f648c5c&vat_number=$value";
    try {
      var response = await http.get(url);
      print(response.body);
      bool valid = jsonDecode(response.body)["valid"];
      return valid;
    }
    catch (e) {
      print(e);
      return false;
    }
  }

  bool mailValid(String mail) {
    return RegExp(
      //*"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'
    ).hasMatch(mail);
  }

  bool validCP(pc) { //marche mais pas fou
    return RegExp(
      //r"^[a-z0-9][a-z0-9\- ]{0,10}[a-z0-9]$"
      r'^(\d{4})$' //belgique et lux ok
    ).hasMatch(pc);
  }
}

//--------------------------------------------------------------------------------
class WaitingPage extends StatelessWidget {
  final _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text("En attente d'approbation", style: Theme.of(context).textTheme.headline2),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  _authService.signOut();
                },
                child: Text("Déconnexion"),
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.white;
                  }),
                  backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled) ? null : Colors.blue;
                  }),
                )
              )
            )
          ],
        )
    );
  }
}