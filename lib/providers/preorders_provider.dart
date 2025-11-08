import 'dart:convert';
import 'dart:developer' as developer;

import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/entities/preorder.dart';
import 'package:compaexpress/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Estado del Provider
class PreordersState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final List<Preorder> preorders;
  final String? errorMessage;

  PreordersState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.preorders = const [],
    this.errorMessage,
  });

  PreordersState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    List<Preorder>? preorders,
    String? errorMessage,
  }) => PreordersState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    isError: isError ?? this.isError,
    preorders: preorders ?? this.preorders,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

/// Provider
final preordersProvider =
    StateNotifierProvider<PreordersNotifier, PreordersState>(
      (ref) => PreordersNotifier(),
    );

class PreordersNotifier extends StateNotifier<PreordersState> {
  PreordersNotifier() : super(PreordersState()) {
    loadPreorders(); // Carga inicial
  }

  final String _key = 'preorder';

  void _log(String message, {String level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    developer.log('[$level][$timestamp] $message', name: 'PreordersNotifier');
  }

  /// Cargar desde SharedPreferences
  Future<void> loadPreorders() async {
    _log('Iniciando carga de preorders desde SharedPreferences...');
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      _log('Valor encontrado en prefs ($_key): $jsonString');

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final preorders = jsonList
            .map((json) => Preorder.fromJson(json))
            .toList();

        _log('Se cargaron ${preorders.length} preorders.');
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          preorders: preorders,
          errorMessage: null,
        );
      } else {
        _log('No existen preorders guardadas.');
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          preorders: [],
          errorMessage: null,
        );
      }
    } catch (e, stack) {
      _log('Error al cargar preorders: $e\n$stack', level: 'ERROR');
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Guardar en SharedPreferences
  Future<void> _savePreorders() async {
    _log(
      'Guardando preorders (${state.preorders.length}) en SharedPreferences...',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.preorders.map((pre) => pre.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
      _log(
        'Preorders guardadas correctamente (${jsonString.length} caracteres).',
      );
    } catch (e, stack) {
      _log('Error al guardar preorders: $e\n$stack', level: 'ERROR');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }

  /// Agregar preorder y persistir
  Future<void> addPreorder({
    required String name,
    String description = '',
    required List<PreorderItem> orderItems,
    required List<PaymentOption> paymentOptions,
    required double totalOrden,
    required double totalPago,
    required double cambio,
    String orderStatus = 'Pagada',
  }) async {
    final id = const Uuid().v4();
    final newPreorder = Preorder(
      id: id,
      name: name,
      description: description,
      orderItems: orderItems,
      paymentOptions: paymentOptions,
      totalOrden: totalOrden,
      totalPago: totalPago,
      cambio: cambio,
      orderStatus: orderStatus,
    );

    _log('Agregando nueva preorder: ${json.encode(newPreorder.toJson())}');
    state = state.copyWith(preorders: [...state.preorders, newPreorder]);
    await _savePreorders();
    _log('Preorder agregada con ID: $id');
    state = state.copyWith(isSuccess: true);
  }

  /// Eliminar por ID y persistir
  Future<void> removePreorder(String id) async {
    _log('Eliminando preorder con ID: $id...');
    final beforeCount = state.preorders.length;
    state = state.copyWith(
      preorders: state.preorders.where((pre) => pre.id != id).toList(),
    );
    final afterCount = state.preorders.length;
    _log('Preorders antes: $beforeCount | después: $afterCount');
    await _savePreorders();
  }

  /// Crear orden a partir de una preorder
  Future<void> createOrderFromPreorder(
    BuildContext context,
    GlobalKey? formKey,
    String preorderId,
    String orderNumber,
    DateTime selectDate,
  ) async {
    try {
      _log('Creando orden a partir de preorder ID: $preorderId...');
      final preorder = state.preorders.firstWhere(
        (pre) => pre.id == preorderId,
      );

      final orderItems = preorder.orderItems.map((item) {
        final orderItem = OrderItemData(
          producto: item.producto,
          precio: item.precio,
          quantity: item.quantity,
          tax: item.tax.toInt(),
        );

        return orderItem;
      }).toList();

      _log(
        'Enviando datos a OrderService.saveOrder: '
        '${json.encode({'items': orderItems, 'total': preorder.totalOrden})}',
      );

      await OrderService.saveOrder(
        context,
        formKey,
        orderItems,
        preorder.totalOrden,
        preorder.totalPago,
        preorder.cambio,
        orderNumber,
        preorder.orderStatus,
        selectDate,
        preorder.paymentOptions,
      );

      _log('Orden creada correctamente desde preorder: $preorderId ✅');
    } catch (e, stack) {
      _log('Error al crear orden desde preorder: $e\n$stack', level: 'ERROR');
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }
}
