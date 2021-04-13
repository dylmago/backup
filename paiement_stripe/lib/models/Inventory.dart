class Inventory {
  String logo;
  String name;
  String type;
  int count;
  String subType;
  String version;

  Inventory(String l, String n, String t, int c, String st, String v) {
    logo = l;
    name = n;
    type = t;
    count = c;
    subType = st;
    version = v;
  }

  factory Inventory.fromJson(dynamic json) {
    if(json['_sub_type'] == null) return Inventory(json['logo'] as String, json['name'] as String, json['_type'] as String, json['count'] as int, null, null);
    else if(json['_version'] == null) return Inventory(json['logo'] as String, json['name'] as String, json['_type'] as String, json['count'] as int, json['_sub_type'] as String, null);
    else return Inventory(json['logo'] as String, json['name'] as String, json['_type'] as String, json['count'] as int, json['_sub_type'] as String, json['_version'] as String);
  }

  /*Inventory.fromJson(dynamic json)
    : logo = json["logo"] as String,
    name = json["name"] as String,
    type = json["_type"] as String,
    count = json["count"] as int;*/

  /*Inventory.fromJson(Map<String, dynamic> json)
    : logo = json["results"]["logo"] as String,
    name = json["results"]["name"] as String,
    type = json["results"]["_type"] as String,
    count = json["results"]["count"] as int;*/

}