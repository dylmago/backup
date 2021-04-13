class Company {
  String name;
  String tvaNum;
  String website;
  var phoneNum;
  var faxNum;
  Adresse generalAdr;
  String generalEmail;
  Adresse invoiceAdr;
  String invoiceEmail;

  Company(String n, String tva, String web, Adresse adG, String mailG, Adresse adI, String mailI, dynamic phone, dynamic fax) {
    name = n;
    tvaNum = tva;
    website = web;
    phoneNum = phone;
    faxNum = fax;
    generalAdr = adG;
    generalEmail = mailG;
    invoiceAdr = adI;
    invoiceEmail = mailI;
  }

  factory Company.fromJson(dynamic json) {
    Adresse adG = new Adresse(
      json['company_g_address'] as String,
      json['company_g_city'] as String,
      json['company_g_postal_code'] as String,
      json['company_g_country'] as String
    );

    Adresse adI = new Adresse(
      json['company_f_address'] as String,
      json['company_f_city'] as String,
      json['company_f_postal_code'] as String,
      json['company_f_country'] as String
    );

    return Company(
      json['company_name'] as String, 
      json['vat_number'] as String, 
      json['company_website'] as String,
      adG,
      json['company_g_mail'] as String,
      adI,
      json['company_f_mail'] as String,
      json['company_phone_number'] as dynamic,
      json['company_fax_number'] as dynamic
    );
  }
}

class Adresse {
  String adresse;
  String city;
  String codeP;
  String country;

  Adresse(String a, String c, String cp, String cnt) {
    adresse = a;
    city = c;
    codeP = cp;
    country = cnt;
  }
}