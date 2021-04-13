@JS()
library stripe;

import 'package:paiement_stripe/services/auth_service.dart';
import 'package:paiement_stripe/models/Product.dart';
import 'package:js/js.dart';

@JS()
class Stripe {
  external Stripe(String key);

  external redirectToCheckout(CheckoutOptions checkoutOptions);
}

Stripe stripe;

initStripe() {
  //stripe = StripeApi('');
  stripe = new Stripe('pk_test_51IONRVL8RLtMYo50Kg7037pCRaIjOlPViRShyzumivKxJQBu5un9iSOHcpUGv5yS4x42GJcLOW3oi87Kq0919amW00uswswXjP');
}

@JS()
@anonymous
class CheckoutOptions {
  external List<LineItem> get lineItems;

  external String get mode;

  external String get successUrl;

  external String get cancelUrl;

  external String get sessionId;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
    String customerEmail,
    //String customer //-> besoin du customerID pour ne pas recréer un nouveau client à chaque paiement
    //clientReferenceId -> test ça si customer ne marche pas avec l'api JS
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;

  external int get quantity;

  external factory LineItem({String price, int quantity});
}

redirectToCheckout(List<Prod> items) async {
  print("redirect to checkout!!!!! ");
  List<LineItem> prods = [];
  for(int i=0; i<items.length; i++) {
    //LineItem item = new LineItem(price: items[i].priceID, quantity: 1);
    LineItem item = new LineItem(price: "price_1IONXUL8RLtMYo50qqVBzI0m", quantity: 1);
    prods.add(item);
  }

  //String customerID = status.stripeID;
  //String customerID;

  try {
    //cas pour quand c'est le premier paiement du client
    var rep = await stripe.redirectToCheckout(CheckoutOptions(
      lineItems: prods,
      mode: 'subscription',
      successUrl: 'http://localhost:4200/#/success/$userEmail/$token',
      cancelUrl: 'http://localhost:4200/#/cancel/$userEmail/$token',
      customerEmail: userEmail,
      //customer: customerID
    ));
    print("Réponse Stripe Checkout: ");
    print(rep.body);
    //if(customerID == null) print("renvoyé le customerID pour maj dans la BD");
    //faire un cas pour quand le client a déjà un customerID dan Stripe.
  }
  catch(e) {
    print("Erreur: " + e);
  }
}