abstract class AuthCredentials {
  //final String username;
  final String email;
  final String password;

  AuthCredentials({this.email, this.password});
}

class LoginCredentials extends AuthCredentials {
  LoginCredentials({String username, String password}) : super(email: username, password: password);
}

class SignUpCredentials extends AuthCredentials {
  final String email;
  //final String name;

  SignUpCredentials({String username, String password, this.email}) : super(email: username, password: password);
}