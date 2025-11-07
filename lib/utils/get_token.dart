import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class GetToken {
  static Future<JsonWebToken?> getIdTokenSimple()async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (session.isSignedIn){
        final cognitoSession = session as CognitoAuthSession;
        final tokens = cognitoSession.userPoolTokensResult.value;
        return tokens.idToken;
      }
      return null;
    } catch (e){
      print('Error al obtener ID token: $e');
      return null;
    }
  }
}
