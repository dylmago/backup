class UserAssoc {
  String email;
  String lastname;
  String firstname;
  String companyId;
  String permission;
  String association;
  String companyName;

  UserAssoc(String e, String l, String f, String cid, String p, String a, String cn) {
    email = e;
    lastname = l;
    firstname = f;
    companyId = cid;
    permission = p;
    association = a;
    companyName = cn;
  }

  factory UserAssoc.fromJson(dynamic json) {
    return UserAssoc(json['email'] as String, 
                json['lastname'] as String, 
                json['firstname'] as String, 
                json['company_id'] as String, 
                json['permission'] as String,
                json['association'] as String,
                json['company_name'] as String);
  }
}