class Product {
  String dbID;
  String dbName;
  String dbSize;
  String subscriptionName;
  double price;
  String priceID;
  Souscription activeSub;

  Product(String id, String dbN, String dbS, String subN, double p, String pid, Souscription actS) {
    dbID = id;
    dbName = dbN;
    dbSize = dbS;
    subscriptionName = subN;
    price = p;
    priceID = pid;
    activeSub = actS;
  }

  factory Product.fromJson(dynamic json) {
    var temp = json["active_subscription"];
    Souscription s;
    if(temp != null) s = new Souscription(temp["active_since"]);
    return Product(json['db_id'] as String, 
                json['db_name'] as String, 
                json['db_size'] as String, 
                json['subscription_name'] as String, 
                json['price'] as double,
                json['price_id'] as String,
                s);
  }

  bool inPanier(List<Product> panier) {
    for(int i=0; i<panier.length; i++) {
      if(panier[i].dbID == this.dbID) return true;
    }
    return false;
  }

  bool isActive() {
    if(this.activeSub != null) return true;
    else return false;
  }
}

class Souscription {
  String activeSince;

  Souscription(String actS) {
    activeSince = actS;
  }
}

class Item {
  String dbID;
  String priceID;
  bool add;

  Item(String id, String pid) {
    dbID = id;
    priceID = pid;
    add = true;
  }
}

//-------------------------------------------------------------------------------------------
class Prod {
  String dbID;
  String logo;
  String type;
  //String version;
  DynObj dbName;
  DynObj dbSize;
  DynObj version;
  DynObj hostname;
  DynObj backupPrice;
  DynObj backupStatus;
  DynObj backupAcivated;

  DynObj port;
  DynObj state;
  DynObj datadir;
  DynObj dbList;
  DynObj edition;
  DynObj startupTime;
  DynObj dbRole;


  Prod(String l, String t, dynamic v, dynamic h) {
    logo = l;
    type = t;
    version= v;
    hostname = h;
  }

  Prod.forBD(String uuid, String l, String t, dynamic dbN, dynamic dbS, dynamic v, dynamic h, dynamic bp, dynamic bs, dynamic ba) {
    dbID = uuid;
    logo = l;
    type = t;
    dbName = dbN;
    dbSize= dbS;
    version= v;
    hostname = h;
    backupPrice = bp;
    backupStatus = bs;
    backupAcivated = ba;
  }

  Prod.details(Prod pr/*, dynamic p, dynamic st, dynamic dd, dynamic dbl, dynamic e, dynamic start, dynamic dbr*/, dynamic json) {
    dbID = pr.dbID;
    logo = pr.logo;
    type = pr.type;
    dbName = pr.dbName;
    dbSize= pr.dbSize;
    version= pr.version;
    hostname = pr.hostname;
    backupPrice = pr.backupPrice;
    backupStatus = pr.backupStatus;
    backupAcivated = pr.backupAcivated;

    var temp = json['port'];
    port = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['state'];
    state = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['datadir'];
    datadir = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['db_list'];
    dbList = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['edition'];
    edition = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['startup_time'];
    startupTime = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    temp = json['database_role'];
    dbRole = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
    /*port = p;
    state = st;
    datadir = dd;
    dbList = dbl;
    edition = e;
    startupTime = start;
    dbRole = dbr;*/
  }

  factory Prod.fromJson(dynamic json) {
    var temp = json['db_name'];
    if(temp != null) { //structure différente pour les bd par rapport au reste
      DynObj name = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['db_size'];
      DynObj size = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['version'];
      DynObj vers = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['hostname'];
      DynObj host = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['backup_price'];
      DynObj backP = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['backup_status'];
      DynObj backStat = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['backup_activated'];
      DynObj backAct = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      return Prod.forBD(json['_uuid'], json['logo'], json['_type'], name, size, vers, host, backP, backStat, backAct);
    }
    else {
      temp = json['version'];
      DynObj vers = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      temp = json['hostname'];
      DynObj host = new DynObj(temp['label'], temp['value'], temp['colour'], temp['visible']);
      return Prod(json['logo'], json['_type'], vers, host);
    }
  }

  bool inPanier(List<Prod> panier) {
    for(int i=0; i<panier.length; i++) {
      if(panier[i].dbID == this.dbID) return true;
    }
    return false;
  }
}

class DynObj {
  String label;
  dynamic value;
  int colour;
  int visible;

  DynObj(String l, dynamic val, int c, int v) {
    label = l;
    value = val;
    colour = c;
    visible = v;
  }
}