import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:http/http.dart' as http;
//import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
//import 'package:amplify_flutter/amplify.dart';
import 'package:paiement_stripe/services/auth_credentials.dart';
import 'package:paiement_stripe/models/Inventory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paiement_stripe/models/Status.dart';
import 'package:paiement_stripe/models/Company.dart';
import 'package:paiement_stripe/models/User.dart';
import 'package:paiement_stripe/models/Obj.dart';
import 'package:paiement_stripe/models/Info.dart';
import 'package:paiement_stripe/models/UserAssoc.dart';
import 'package:paiement_stripe/models/Product.dart';
import 'package:url_launcher/url_launcher.dart';

enum AuthFlowStatus { login, signUp, verification, session }

CognitoUser user;
//List<CognitoUserAttribute> attributes;
String token;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
//String uid;
String userEmail;
//String name;

Status status;

List<Objet> salutations;
List<Objet> callMethods;
List<Objet> permissions;
List<Objet> associations;

List<Utilisateur> compUsers;
List<Inventory> invs;
List<UserAssoc> userAssociations;

List<Prod> prods;
List<Prod> panier;

List<Product> products;
//List<Product> panier;
//List<Item> panier;

Info info;
Company company;

class AuthState {
  final AuthFlowStatus authFlowStatus;

  AuthState({this.authFlowStatus});
}

class AuthService {
  final authStateController = StreamController<AuthState>();

  AuthCredentials _credentials;

  void showSignUp() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.signUp);
    authStateController.add(state);
  }

  void showLogin() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.login);
    authStateController.add(state);
  }

  reconnect(String email, String tok) async {
    final userPool = new CognitoUserPool(
      'eu-central-1_tZRo6LWQR',
      '6q0tm8lojt6riv873vcij7hlss'
    );
    user = new CognitoUser(email, userPool);
    userEmail = email;
    token = tok;
    panier = [];
    await getStatus();
    if(status.stat == 300) await getInv();
  }

  login(AuthCredentials credentials) async {
    final userPool = new CognitoUserPool(
      'eu-central-1_tZRo6LWQR',
      '6q0tm8lojt6riv873vcij7hlss'
    );
    final cognitoUser = new CognitoUser(credentials.email, userPool);
    final authDetails = new AuthenticationDetails(
      username: credentials.email,
      password: credentials.password,
    );
    CognitoUserSession session;

    try {
      session = await cognitoUser.authenticateUser(authDetails);
      if (session.getIdToken() != null) {
        print("User logged !!!");
        userEmail = credentials.email;
        user = cognitoUser;
        //attributes = await user.getUserAttributes();
        //on récupère les objets distants
        token = session.getIdToken().getJwtToken();
        await getStatus();
        if(status.stat == 1) {
          await getSalutations();
          await getCallMethods();
        }
        else if(status.stat == 300) {
          await getInv();
          panier = [];
        }
        final state = AuthState(authFlowStatus: AuthFlowStatus.session);
        authStateController.add(state);
      } 
      else {
        print('User could not be signed in');
      }
    } on CognitoUserConfirmationNecessaryException {
      print("Cet utilisateur n'a pas été confirmé");
    } on CognitoClientException {
      print("Cet utilisateur n'existe pas ou le mot de passe entré était incorrect");
    } catch (e) {
      print(e);
    }
  }

  void signUp(SignUpCredentials credentials) async {
    final userPool = new CognitoUserPool(
      'eu-central-1_tZRo6LWQR',
      '6q0tm8lojt6riv873vcij7hlss'
    );
    final userAttributes = [
      new AttributeArg(name: 'email', value: credentials.email)
    ];
    //final cognitoUser = new CognitoUser(_credentials.username, userPool);
    try {
      await userPool.signUp(
        credentials.email,
        credentials.password,
        userAttributes: userAttributes,
      );
      this._credentials = credentials;
      final state = AuthState(authFlowStatus: AuthFlowStatus.verification);
      authStateController.add(state);
    } 
    on Exception catch(e) {
      print(e);
    }
    catch(UsernameExistException) {
      login(credentials);
    }
  }

  void verifyCode(String verificationCode) async {
    final userPool = new CognitoUserPool(
      'eu-central-1_tZRo6LWQR',
      '6q0tm8lojt6riv873vcij7hlss'
    );
    final cognitoUser = new CognitoUser(_credentials.email, userPool);
    bool registrationConfirmed = false;
    try {
      registrationConfirmed = await cognitoUser.confirmRegistration(verificationCode);
    } catch (e) {
      print(e);
    }
    if(registrationConfirmed) login(_credentials); //connexion automatique après avoir terminer de s'enregistrer !!!
  }

  void signOut() async {
    token = null;
    userEmail = null;
    status = null;
    compUsers = [];
    invs = [];
    userAssociations = [];
    products = [];
    panier = [];
    if(user != null) {
      try {
        await user.signOut();
        user = null;
        //attributes = null;
        print("disconnected !");
        showLogin();
      }
      catch(e) {
        print(e);
      }
    }
    else signOutGoogle();
  }

  //fait appel à l'API renvoyant le statut de l'utlilisateur
  getStatus() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/userstatus/';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['body'];
      status = Status.fromJson(rep);
    }
    catch (e) {
      print(e);
    }
  }

  //appelle l'API renvoyant la liste des salutations
  getSalutations() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/discovery/setup/salutation';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token,
        "content-type": "application/json",
      });
      var rep = jsonDecode(response.body)['body'] as List;
      salutations = [];
      for(int i=0; i<rep.length; i++) {
        //Salutation slt = Salutation.fromJson(rep[i]);
        Objet slt = Objet.fromJson(rep[i]);
        salutations.add(slt);
      }
    }
    catch (e) {
      print(e);
    }
  }

  //appelle l'API renvoyant la liste des moéthodes de notification
  getCallMethods() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/discovery/setup/callmethod';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token,
        "content-type": "application/json",
      });
      var rep = jsonDecode(response.body)['body'] as List;
      callMethods = [];
      for(int i=0; i<rep.length; i++) {
        //CallMethod cm = CallMethod.fromJson(rep[i]);
        Objet cm = Objet.fromJson(rep[i]);
        callMethods.add(cm);
      }
    }
    catch (e) {
      print(e);
    }
  }

  //appelle l'API renvoyant la liste des permissions
  getPermissions() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/discovery/setup/permission';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token,
        "content-type": "application/json",
      });
      var rep = jsonDecode(response.body)['body'] as List;
      permissions = [];
      for(int i=0; i<rep.length; i++) {
        Objet o = Objet.fromJson(rep[i]);
        permissions.add(o);
      }
    }
    catch (e) {
      print(e);
    }
  }

  //appelle l'API renvoyant la liste des associations possibles
  getAssoc() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/discovery/setup/association'; //url à changer !!
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token,
        "content-type": "application/json",
      });
      var rep = jsonDecode(response.body)['body'] as List;
      associations = [];
      for(int i=0; i<rep.length; i++) {
        Objet o = Objet.fromJson(rep[i]);
        associations.add(o);
      }
    }
    catch (e) {
      print(e);
    }
  }

  //fait appel à l'API renvoyant les infos de l'utlilisateur
  getInfos() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/user/';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['body'];
      info = Info.fromJson(rep);
      //return info;
    }
    catch (e) {
      print(e);
      return null;
    }
  }

  //envoie les infos de l'utilisateur vers le backend
  postInfos(int csid, String n, String p, dynamic tel, dynamic telF, int cm, int nm) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/user/';
    try {
      var obj = {
        "lastname": n,
        "firstname": p,
        "contact_salutation_id": csid,
        "mobile_number": tel,
        if(telF!= null) "phone_number": telF,
        "prefered_call_method" : cm,
        "prefered_notify_method": nm
      };
      final msg = jsonEncode(obj);
      //print(msg);
      var response = await http.post(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
      //await getStatus();
    }
    catch (e) {
      print(e);
    }
  }

  //fait appel à l'API renvoyant les infos de la compagnie de l'utilisateur
  getCompany() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/company/';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['body'];
      company = Company.fromJson(rep);
    }
    catch (e) {
      print(e);
      return null;
    }
  }
  
  //envoie les infos de la compagnie vers le backend
  postCompany(Company comp) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/company/';
    try {
      print("envoie des infos de la compagnie !!!!!!");
      var obj = {
        "company_name": comp.name,
        "vat_number": comp.tvaNum,
        "company_website": comp.website,
        "company_g_address": comp.generalAdr.adresse,
        "company_g_city": comp.generalAdr.city,
        "company_g_postal_code": comp.generalAdr.codeP,
        "company_g_country": comp.generalAdr.country,
        "company_g_mail": comp.generalEmail,
        "company_f_address": comp.invoiceAdr.adresse,
        "company_f_city": comp.invoiceAdr.city,
        "company_f_postal_code": comp.invoiceAdr.codeP,
        "company_f_country": comp.invoiceAdr.country,
        "company_f_mail": comp.invoiceEmail,
        "company_phone_number" : comp.phoneNum,
        "company_fax_number": comp.faxNum
      };
      final msg = jsonEncode(obj);
      //print(msg);
      var response = await http.post(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
      //await getStatus();
    }
    catch (e) {
      print(e);
    }
  }

  //appelle l'API associant l'utilisateur à la compagnie correspondant à cet uuid
  associateUser(String uuid) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/company/association';
    try {
      var obj = {
        "company_uuid": uuid
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.post(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
      //await getStatus();
    }
    catch (e) {
      print(e);
    }
  }

   //fait appel à l'API renvoyant la liste des utilisateurs associés à la compagnie
  getCompUsers() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/company/association';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['body'] as List;
      print(rep);
      compUsers = [];
      for(int i=0; i<rep.length; i++) {
        Utilisateur u = Utilisateur.fromJson(rep[i]);
        compUsers.add(u);
      }
      //status = Status.fromJson(rep);
    }
    catch (e) {
      print(e);
    }
  }

  //API permettant de modifier les permissions et le status d'association d'un utilisateur dans une compagnie
  postCompUsers(int permitID, String mail, int assocID) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/company/association';
    try {
      /*int permit;
      if(compUsers[index].permission == "admin") permit = 1;
      else if(compUsers[index].permission == "owner") permit = 3;
      else permit = 2;*/
      /*int assoc;
      if(compUsers[index].association == "Approved") assoc = 0;
      else if(compUsers[index].association == "Waiting for approval") assoc = 1;
      else assoc = 3;*/
      var obj = {
        "permission": permitID,
        "email": mail,
        "association": assocID
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.put(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
    }
    catch (e) {
      print(e);
    }
  }

  //fait appel à l'API renvoyant la liste des compagnies auxquelles l'utilisateur est associé
  getUserAssoc() async {
    //var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev//app/user/association';
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/user/association';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['body'] as List;
      userAssociations = [];
      for(int i=0; i<rep.length; i++) {
        UserAssoc u = UserAssoc.fromJson(rep[i]);
        userAssociations.add(u);
      }
    }
    catch (e) {
      print(e);
    }
  }

  getAgents() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/discovery/setup/agent';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      //var rep = jsonDecode(response.body)['body'] as List;
      /*userAssociations = [];
      for(int i=0; i<rep.length; i++) {
        UserAssoc u = UserAssoc.fromJson(rep[i]);
        userAssociations.add(u);
      }*/
    }
    catch (e) {
      print(e);
    }
  }

  getInv() async {
    //var url = 'https://webhook.site/6189d63b-ce4d-4102-8191-c75781260ff3';
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/inventory/';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      //print(response.body);
      var l = jsonDecode(response.body)['body'] as List;
      print(l);
      invs = [];
      for(int i=0; i<l.length; i++){
        Inventory inv = Inventory.fromJson(l[i]);
        invs.add(inv);
      }
    }
    catch (e) {
      print(e);
    }
  }

  getInvSvc(String svc) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/inventory/$svc';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      if(jsonDecode(response.body)['app_res'] == -1) return -1;
      var rep = jsonDecode(response.body)['body'] as List;
      invs = [];    
      for(int i=0; i<rep.length; i++){
        Inventory inv = Inventory.fromJson(rep[i]);
        invs.add(inv);
      }
      return 0;
    }
    catch (e) {
      print(e);
    }
  }

  getInvSvcType(String svc, String type) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/inventory/$svc/$type';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      if(jsonDecode(response.body)['app_res'] == -1) return -1;
      var rep = jsonDecode(response.body)['body'] as List;
      invs = [];    
      for(int i=0; i<rep.length; i++){
        Inventory inv = Inventory.fromJson(rep[i]);
        invs.add(inv);
      }
      return 0;
    }
    catch (e) {
      print(e);
    }
  }

  getInvSvcTypeVersion(String svc, String type, String version) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/inventory/$svc/$type/$version';
    print(url);
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      //if(jsonDecode(response.body)['app_res'] == -1) return -1;
      var rep = jsonDecode(response.body)['body'] as List;
      prods = [];    
      for(int i=0; i<rep.length; i++){
        Prod prod = Prod.fromJson(rep[i]);
        prods.add(prod);
      }
    }
    catch (e) {
      print(e);
    }
  }

  getInfoObj(String id, String type) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/app/inventory/object?uuid=$id&type=$type';
    print(url);
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      //if(jsonDecode(response.body)['app_res'] == -1) return -1;
      var rep = jsonDecode(response.body)['body'];
      //prods = [];
      int i = 0;
      while(i<prods.length && prods[i].dbID != id) {
        i++;
      }
      Prod prod = Prod.details(prods[i], rep);
      print(prod.dbName.value);
      print(prod.startupTime.value);
      print(prod.dbList.value);
      return prod;
    }
    catch (e) {
      print(e);
    }
  }

  getProducts() async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/stripe/available-items';
    try {
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: token
      });
      print(response.body);
      var rep = jsonDecode(response.body)['db'] as List;
      //print(rep);
      products = [];
      for(int i=0; i<rep.length; i++) {
        Product prod = Product.fromJson(rep[i]);
        products.add(prod);
      }
    }
    catch (e) {
      print(e);
    }
  }

  emitPaymentToServer(String tokenID) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/stripe/available-items';
    try {
      List items = [];
      for(int i=0; i<panier.length; i++) {
        var item = {
          "db_id" : panier[i].dbID,
          //"add" : panier[i].add,
          "add" : true,
        };
        items.add(item);
      }
      print(items);
      var obj = {
        "status_code": 200,
        //"email": userEmail,
        "items": items,
        "token": tokenID,
        //"customer_id": // -> null sauf pour le premier paiement sur le web (je dois le renvoyé pour qu'on puisse le mettre dans la BD)
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.post(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
      return(response.body);
    }
    catch(e) {
      print(e);
    }
  }

  //supprime la subscription Stripe correspondant à cette DB
  deleteSubscription(String id) async {
    var url = 'https://dpfv3bnyg0.execute-api.eu-central-1.amazonaws.com/dev/stripe/available-items';
    try {
      List items = [];
      var item = {
        "db_id": id,
        "add": false,
      };
      items.add(item);
      var obj = {
        "status_code": 200,
        "items": items,
        "token": null,
        "session": null,
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.post(
        url, 
        headers: {
          HttpHeaders.authorizationHeader: token,
          "Accept": "application/json",
          "content-type": "application/json",
        },
        body: msg
      );
      print(response.body);
    }
    catch(e) {
      print(e);
    }
  }

  createRedirectFlowGoCL() async {
    var url = 'https://api-sandbox.gocardless.com/redirect_flows';
    try {
      await getInfos();
      var customer = {
        "given_name": info.firstname,
        "family_name": info.lastname,
        "email": info.email
      };
      var redirectFlow = {
        "description" : "test",
        "session_token": token.split("-")[1],
        "success_redirect_url": "http://localhost:4200/#/mandat/$userEmail/$token",
        "prefilled_customer": customer,
      };
      //print(redirectFlow);
      var obj = {
        "redirect_flows": redirectFlow
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.post(
        url, 
        headers: {
          "Authorization": "Bearer sandbox_dw-3XkC6SHPk1VkHi0eS0jZ17cefTVHejkpE6-8D", //access_token
          //"Authorization": "Bearer tCHeLuMszp4DiTgBasfgmzTSZ-MbAjQmjSbYa4jH", //publishable acces_token
          "Accept": "application/json",
          "content-type": "application/json",
          "GoCardless-Version": "2015-07-06"
        },
        body: msg
      );
      print(response.body);
      var rep = jsonDecode(response.body)['redirect_flows'];
      //print(rep);
      print(rep['redirect_url']);
      await launch(rep['redirect_url']);
    }
    catch(e) {
      print(e);
    }
  }

  confirmRedirectFlowGCL(String sid) async {
    print("confirmation !!!!!!");
    var url = 'https://api-sandbox.gocardless.com/redirect_flows/$sid/actions/complete';
    try {
      var tok = {
        "session_token": token.split("-")[1],
      };
      var obj = {
        "data": tok
      };
      final msg = jsonEncode(obj);
      print(msg);
      var response = await http.post(
        url, 
        headers: {
          "Authorization": "Bearer sandbox_dw-3XkC6SHPk1VkHi0eS0jZ17cefTVHejkpE6-8D", //access_token
          //"Authorization": "Bearer tCHeLuMszp4DiTgBasfgmzTSZ-MbAjQmjSbYa4jH", //publishable acces_token
          "Accept": "application/json",
          "content-type": "application/json",
          "GoCardless-Version": "2015-07-06"
        },
        body: msg
      );
      print(response.body);
    }
    catch(e) {
      print(e);
    }
  }

  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    token = await user.getIdToken();

    if (user != null) {
      // Checking if email and name is null
      //assert(user.uid != null);
      assert(user.email != null);
      //assert(user.displayName != null);
      //assert(user.photoURL != null);

      //uid = user.uid;
      //name = user.displayName;
      userEmail = user.email;
      //imageUrl = user.photoURL;

      /*if (name.contains(" ")) { //seulement garder le prénom
        name = name.substring(0, name.indexOf(" "));
      }*/

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      //final User currentUser = _auth.currentUser;
      //assert(user.uid == currentUser.uid);

      //final state = AuthState(authFlowStatus: AuthFlowStatus.session);
      //authStateController.add(state);

      try { //erreur ici (sans doute le token qui Google qui marche pas)
        //await getAPI();
        //getStatus();
      }
      catch (e) {
        print(e);
      }
      return "";
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);*/
    //userEmail = null;
    print("User signed out of Google account");
  }
}