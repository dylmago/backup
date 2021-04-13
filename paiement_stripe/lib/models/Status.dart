class Status {
  bool admin;
  bool owner;
  int stat;

  Status(int s, bool a, bool o) {
    stat = s;
    admin = a;
    owner = o;
  }

  factory Status.fromJson(dynamic json) {
    return Status(json['status'] as int, json['admin'] as bool, json['owner'] as bool);
  }

  /*Status.fromJson(Map<String, dynamic> json)
    : stat = bool.parse(json["results"]["status"]);*/

}