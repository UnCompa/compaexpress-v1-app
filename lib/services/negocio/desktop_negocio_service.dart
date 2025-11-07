// services/negocio/desktop_negocio_service.dart
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/user_info.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio/negocio_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DesktopNegocioService implements NegocioManager {
  @override
  Future<Negocio?> getNegocioById(String id) async {
    final request = ModelQueries.get(
      Negocio.classType,
      NegocioModelIdentifier(id: id),
    );
    final response = await Amplify.API.query(request: request).response;
    return response.data;
  }

  @override
  Future<List<Negocio>> getAllNegocios() async {
    final request = ModelQueries.list(Negocio.classType);
    final response = await Amplify.API.query(request: request).response;
    return response.data?.items.whereType<Negocio>().toList() ?? [];
  }

  @override
  Future<Negocio> createNegocio(Negocio negocio) async {
    final request = ModelMutations.create(negocio);
    final response = await Amplify.API.mutate(request: request).response;
    return response.data!;
  }

  @override
  Future<Negocio> updateNegocio(Negocio negocio) async {
    final request = ModelMutations.update(negocio);
    final response = await Amplify.API.mutate(request: request).response;
    return response.data!;
  }

  @override
  Future<bool> deleteNegocio(String id) async {
    final negocio = await getNegocioById(id);
    if (negocio != null) {
      final request = ModelMutations.delete(negocio);
      final response = await Amplify.API.mutate(request: request).response;
      return response.data != null;
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
