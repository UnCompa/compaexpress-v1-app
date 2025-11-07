// services/negocio/mobile_negocio_service.dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/user_info.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio/negocio_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MobileNegocioService implements NegocioManager {
  @override
  Future<Negocio?> getNegocioById(String id) async {
    final result = await Amplify.DataStore.query(
      Negocio.classType,
      where: Negocio.ID.eq(id),
    );
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<List<Negocio>> getAllNegocios() async {
    final negocios = await Amplify.DataStore.query(Negocio.classType);
    return negocios;
  }

  @override
  Future<Negocio> createNegocio(Negocio negocio) async {
    await Amplify.DataStore.save(negocio);
    return negocio;
  }

  @override
  Future<Negocio> updateNegocio(Negocio negocio) async {
    await Amplify.DataStore.save(negocio);
    return negocio;
  }

  @override
  Future<bool> deleteNegocio(String id) async {
    final negocio = await getNegocioById(id);
    if (negocio != null) {
      await Amplify.DataStore.delete(negocio);
      return true;
    }
    return false;
  }

  @override
  Future<UserInfo> getCurrentUserInfo() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    final idToken = session.userPoolTokensResult.value.idToken;
    final payload = JwtDecoder.decode(idToken.raw);
    final groups = (payload['cognito:groups'] ?? []).cast<String>();

    final attributes = await Amplify.Auth.fetchUserAttributes();
    final email = attributes
        .firstWhere((a) => a.userAttributeKey == CognitoUserAttributeKey.email)
        .value;
    final negocioId = attributes
        .firstWhere(
          (a) =>
              a.userAttributeKey == CognitoUserAttributeKey.custom("negocioId"),
        )
        .value;

    return UserInfo(
      userId: authUser.userId,
      username: authUser.username,
      email: email,
      groups: groups,
      negocioId: negocioId,
    );
  }

  @override
  Future<bool> hasPermission(String operation) async {
    final userInfo = await getCurrentUserInfo();
    if (userInfo.isSuperAdmin) return true;
    if (userInfo.isAdmin) return ['read', 'update'].contains(operation);
    if (userInfo.isVendedor) return operation == 'read';
    return false;
  }
}
