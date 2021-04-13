class Info {
  String lastname;
  String firstname;
  String email;
  int salutID;
  dynamic phoneNum;
  dynamic mobileNum;
  int callM;
  int notifyM;

  Info(String l, String f, String e, int sid, dynamic phone, dynamic mobile, int cm, int nm) {
    lastname = l;
    firstname = f;
    email = e;
    salutID = sid;
    phoneNum = phone;
    mobileNum = mobile;
    callM = cm;
    notifyM = nm;
  }

  factory Info.fromJson(dynamic json) {
    return Info(json['lastname'] as String, 
                json['firstname'] as String, 
                json['email'] as String, 
                json['contact_salutation_id'] as int,
                json['phone_number'],
                json['mobile_number'],
                json['prefered_call_method'] as int,
                json['prefered_notify_method'] as int);
  }
}