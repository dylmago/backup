class Utilisateur {
  String email;
  String lastname;
  String firstname;
  String companyId;
  String permission;
  String association;

  Utilisateur(String e, String l, String f, String cid, String p, String a) {
    email = e;
    lastname = l;
    firstname = f;
    companyId = cid;
    permission = p;
    association = a;
  }

  factory Utilisateur.fromJson(dynamic json) {
    return Utilisateur(json['email'] as String, 
                json['lastname'] as String, 
                json['firstname'] as String, 
                json['company_id'] as String, 
                json['permission'] as String,
                json['association'] as String);
  }
}