import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/nav_section.dart';
import 'package:http/http.dart' as http;
import 'package:paiement_stripe/main.dart';
import 'package:paiement_stripe/models/Obj.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback shouldShowNext;

  ProfilePage({Key key, this.shouldShowNext}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Widget navSection;
  final _authService = AuthService();
  String title;
  //final _userService = UserService();
  var _nameController;
  var _firstnameController;
  var _numTelController;
  var _fixedTelController = TextEditingController();
  String salutation;
  String cmethod;
  String nmethod;
  String codeM;
  String codeF = 'BE';

  bool numValid = false;
  bool numFixValid = true;

  @override
  void initState() {
    super.initState();
    if(info == null) {
      title = "Please complete you user profile";
      _nameController = TextEditingController();
      _firstnameController = TextEditingController();
      _numTelController = TextEditingController();
      salutation = salutations[0].title;
      cmethod = callMethods[0].title;
      nmethod = callMethods[0].title;
      codeM = 'BE';
    }
    else {
      title = "User Profile";
      _nameController = TextEditingController(text: info.lastname);
      _firstnameController = TextEditingController(text: info.firstname);
      _numTelController = TextEditingController(text: info.mobileNum['local_format'].toString().substring(1));
      salutation = salutations[info.salutID-1].title;
      for(int i =0;i < callMethods.length; i++) {
        if(info.callM == callMethods[i].id) cmethod = callMethods[i].title;
        if(info.notifyM == callMethods[i].id) nmethod = callMethods[i].title;
      }
      codeM = info.mobileNum['country_code']; 
      if(info.phoneNum != null) { //le substring est pour enlever le 0 au début du numéro
        _fixedTelController = TextEditingController(text: info.phoneNum['local_format'].toString().substring(1));
        codeF = info.phoneNum['country_code'];
      }
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
    if(info == null) {
      return Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: _profileForm(),
          ),
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
          child: Form(
            key: _formKey,
            child: _profileForm(),
          ),
        ),
      );
    }
  }

  Widget _profileForm() {
    if(isSmallScreen(context)) {
      return ListView(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
          SizedBox(height: 10),
          salutationWidget(),
          nameInput(),
          firstNameInput(),
          emailInput(),
          SizedBox(height: 5),
          mobileInput(),
          fixedNumInput(),
          SizedBox(height: 5),
          callMethod(),
          notifyMethod(),
          SizedBox(height: 10),
          buttonValidate()
        ],
      );
    }
    else {
      return Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            child: Text(title, style: Theme.of(context).textTheme.headline2),
          ),
          SizedBox(height: 20),
          salutationWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: nameInput()
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: firstNameInput(),
                ) 
              ),
            ],
          ),
          SizedBox(height: 20),
          emailInput(),
          SizedBox(height: 20),
          Row(
            children: [
              Flexible(child: mobileInput()),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: fixedNumInput(),
                )
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              callMethod(),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.2,
                child: notifyMethod(),
              ),
            ]
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 40,
            width: 100,
            child: buttonValidate(),
          )
        ],
      );
    }
  }

  Widget nameInput() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(icon: Icon(Icons.person), labelText: 'Nom'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget firstNameInput() {
    return TextFormField(
      controller: _firstnameController,
      decoration: InputDecoration(icon: Icon(Icons.person), labelText: 'Prénom'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget emailInput() {
    return TextField(
      enabled: false,
      decoration: InputDecoration(icon: Icon(Icons.mail), labelText: userEmail),
    );
  }

  Widget mobileInput() {
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
              controller: _numTelController,
              decoration: InputDecoration(
                labelText: 'Mobile Phone Number',
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

  Widget fixedNumInput() {
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
              controller: _fixedTelController,
              decoration: InputDecoration(
                labelText: 'Fixed Phone Number',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
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

  Widget salutationWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Salutations "), //mettre du style au texte (+ grand)
        ),
        DropdownButton<String>(
          value: salutation,
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          elevation: 16,
          style: TextStyle(color: cartesoftBlueLight2),
          underline: Container(
            height: 2,
            color: cartesoftBlueLight1,
          ),
          onChanged: (String newValue) {
            setState(() {
              salutation = newValue;
            });
          },
          items: salutations
          .map<DropdownMenuItem<String>>((Objet value) {
            return DropdownMenuItem<String>(
              value: value.title,
              child: Text(value.title),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget buttonValidate() {
    return TextButton(
      onPressed: () async {
        var phone;
        if(_numTelController.text.isNotEmpty) {
          phone = await validateMobile(_numTelController.text.trim(), codeM);
          numValid = jsonDecode(phone)["valid"];
        }
        var fixedPhone;
        if(_fixedTelController.text.isNotEmpty) {
          fixedPhone = await validateMobile(_fixedTelController.text.trim(), codeF);
          numFixValid = jsonDecode(phone)["valid"];
        }
        _formKey.currentState.save();
        if(_formKey.currentState.validate()) {
          print(status.stat);
          await completeProfile(phone, fixedPhone);
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

  Widget callMethod() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Call Method "), //mettre du style au texte (+ grand)
        ),
        DropdownButton<String>(
          value: cmethod,
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          elevation: 16,
          style: TextStyle(color: cartesoftBlueLight2),
          underline: Container(
            height: 2,
            color: cartesoftBlueLight1,
          ),
          onChanged: (String newValue) {
            setState(() {
              cmethod = newValue;
            });
          },
          items: callMethods
          .map<DropdownMenuItem<String>>((Objet value) {
            return DropdownMenuItem<String>(
              value: value.title,
              child: Text(value.title),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget notifyMethod() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text("Notify Method "), //mettre du style au texte (+ grand)
        ),
        DropdownButton<String>(
          value: nmethod,
          icon: Icon(Icons.arrow_downward),
          iconSize: 20,
          elevation: 16,
          style: TextStyle(color: cartesoftBlueLight2),
          underline: Container(
            height: 2,
            color: cartesoftBlueLight1,
          ),
          onChanged: (String newValue) {
            setState(() {
              nmethod = newValue;
            });
          },
          items: callMethods
          .map<DropdownMenuItem<String>>((Objet value) {
            return DropdownMenuItem<String>(
              value: value.title,
              child: Text(value.title),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  completeProfile(dynamic mobilephone, dynamic fixedPhone) {
    final nom = _nameController.text.trim();
    final prenom = _firstnameController.text.trim();
    //final tel = _numTelController.text.trim();
    if(numValid) {
      int id;
      for(int i = 0; i < salutations.length; i++) {
        if(salutations[i].title == salutation) id = salutations[i].id;
      }
      int cmethodID;
      for(int i = 0; i < callMethods.length; i++) {
        if(callMethods[i].title == cmethod) cmethodID = callMethods[i].id;
      }
      int nmethodID;
      for(int i = 0; i < callMethods.length; i++) {
        if(callMethods[i].title == nmethod) nmethodID = callMethods[i].id;
      }
      _authService.postInfos(id, nom, prenom, mobilephone, fixedPhone, cmethodID, nmethodID);
      //_authService.getInfos();
    }
    else print("numéro incorrect");
  }

  Future<dynamic> validateMobile(String value, String code) async {
    //var url = "http://apilayer.net/api/validate?access_key=235faa57fbf72659bde728b6ed5132c7&number='$value'";
    var url = "http://apilayer.net/api/validate?access_key=235faa57fbf72659bde728b6ed5132c7&number='$value'&country_code=$code";
    try {
      var response = await http.get(url);
      print(response.body);
      //print(jsonDecode(response.body)["international_format"]);
      //numTel = jsonDecode(response.body)["international_format"];
      return response.body;
      //if(jsonDecode(response.body)["valid"]) return true;
      //else return false;
    }
    catch (e) {
      print(e);
    }
  }

  bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }
  //Small screen is any screen whose width is less than 800 pixels
  bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }
  //Medium screen is any screen whose width is less than 1200 pixels and more than 800 pixels
  bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800 &&
    MediaQuery.of(context).size.width < 1200;
  }
}