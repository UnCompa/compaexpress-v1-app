import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<String> getRolUser() async {
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    final roleAttr = userAttributes.firstWhere(
      (attr) => attr.userAttributeKey.key == 'custom:role',
      orElse: () => const AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.custom('role'),
        value: 'unknown',
      ),
    );

    final role = roleAttr.value.toLowerCase();
    return role;
  }

  static Future<void> saveUserRoleLocally(String role) async {
    debugPrint("Guardando rol localmente: $role");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<String?> getUserRoleLocally() async {
    debugPrint("Obteniendo rol localmente");
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<UsersResponse?> fetchUsersSellers() async {
    try {
      final info = await NegocioService.getCurrentUserInfo();
      final negocioId = info.negocioId;
      var token = await GetToken.getIdTokenSimple();
      if (token == null) {
        debugPrint('No se pudo obtener el token');
        return null;
      }
      final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
      final response = await http.get(
        Uri.parse('$apiUrl/users?negocioId=$negocioId&groupName=vendedor'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": token.raw,
        },
      );
      debugPrint("ESTADO DE LA CONSULTA: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint("DATOS: $jsonData");
        final usersResponse = UsersResponse.fromJson(jsonData);
        return usersResponse;
      }
      return null;
    } catch (e) {
      debugPrint("Error al obtener los usuarios $e");
    }
    return null;
  }

  static Future<bool> desactivateUser(String email) async {
    try {
      var token = await GetToken.getIdTokenSimple();
      if (token == null || token.raw.isEmpty) {
        debugPrint('Error: No se pudo obtener el token o el token está vacío');
        return false;
      }

      final String apiUrl = dotenv.env['API_URL'] ?? '';
      if (apiUrl.isEmpty) {
        debugPrint('Error: URL de la API no encontrada en .env');
        return false;
      }

      final body = jsonEncode({'email': email});

      final response = await http.post(
        Uri.parse('$apiUrl/desactivateuser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token.raw,
        },
        body: body,
      );
      print("RESPUESTA: $response");

      if (response.statusCode == 200) {
        debugPrint('Usuario desactivado exitosamente: $email');
        return true;
      } else {
        debugPrint(
          'Error al desactivar usuario: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error al desactivar usuario: $e');
      return false;
    }
  }
}
