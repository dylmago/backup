class Objet {
  String title;
  int id;

  Objet(String t, int i) {
    title = t;
    this.id = i;
  }

  factory Objet.fromJson(dynamic json) {
    return Objet(json['title'] as String, json['id'] as int);
  }
}