import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

// Estados
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int itemsPerPage;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.itemsPerPage = 4,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  List<Order> get paginatedOrders {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return orders.sublist(start, end > orders.length ? orders.length : end);
  }

  int get totalPages => (orders.length / itemsPerPage).ceil();
}

class FilterState {
  final String? selectedSellerId;
  final String? selectedDate;

  FilterState({this.selectedSellerId, this.selectedDate});

  FilterState copyWith({
    String? selectedSellerId,
    String? selectedDate,
    bool clearSeller = false,
    bool clearDate = false,
  }) {
    return FilterState(
      selectedSellerId: clearSeller
          ? null
          : (selectedSellerId ?? this.selectedSellerId),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    );
  }

  bool get hasActiveFilters => selectedSellerId != null || selectedDate != null;
}

// Notifier para gestionar órdenes
class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState());

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final negocio = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Order.classType,
        where:
            Order.ISDELETED.eq(false) & Order.NEGOCIOID.eq(negocio.negocioId),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final orders = response.data!.items.whereType<Order>().toList();
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        state = state.copyWith(orders: orders, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Error al cargar órdenes: ${response.errors}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado: $e',
      );
    }
  }

  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void updateOrders(List<Order> orders) {
    state = state.copyWith(orders: orders, currentPage: 1);
  }
}

// Notifier para vendedores
class SellersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  SellersNotifier() : super(const AsyncValue.loading()) {
    loadSellers();
  }

  Future<void> loadSellers() async {
    state = const AsyncValue.loading();

    try {
      final info = await NegocioService.getCurrentUserInfo();
      final negocioId = info.negocioId;
      final token = await GetToken.getIdTokenSimple();

      if (token == null) {
        state = AsyncValue.error(
          'No se pudo obtener el token',
          StackTrace.current,
        );
        return;
      }

      final String apiUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.get(
        Uri.parse('$apiUrl/users?negocioId=$negocioId&groupName=vendedor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token.raw,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final usersResponse = UsersResponse.fromJson(jsonData);
        state = AsyncValue.data(usersResponse.users);
      } else {
        state = AsyncValue.error(
          'Error al cargar usuarios: ${response.statusCode}',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Notifier para filtros
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setSellerFilter(String? sellerId) {
    state = state.copyWith(selectedSellerId: sellerId);
  }

  void setDateFilter(String? date) {
    state = state.copyWith(selectedDate: date);
  }

  void clearFilters() {
    state = FilterState();
  }
}

// Providers
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

final sellersProvider =
    StateNotifierProvider<SellersNotifier, AsyncValue<List<User>>>((ref) {
      return SellersNotifier();
    });

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});

// Provider computado para órdenes filtradas
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final orderState = ref.watch(orderProvider);
  final filterState = ref.watch(filterProvider);
  final sellersAsync = ref.watch(sellersProvider);

  if (!filterState.hasActiveFilters) {
    return orderState.orders;
  }

  return orderState.orders.where((order) {
    bool matchesSeller = true;
    bool matchesDate = true;

    // Filtro por vendedor
    if (filterState.selectedSellerId != null) {
      matchesSeller =
          order.sellerID.toLowerCase() ==
          filterState.selectedSellerId!.toLowerCase();
    }

    // Filtro por fecha
    if (filterState.selectedDate != null) {
      final DateTime orderDate = order.orderDate.getDateTimeInUtc();
      final formattedOrderDate =
          "${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}";

      String formattedFilterDate;
      try {
        final DateTime parsed = DateTime.parse(filterState.selectedDate!);
        formattedFilterDate =
            "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      } catch (e) {
        formattedFilterDate = filterState.selectedDate!;
      }

      matchesDate = formattedOrderDate == formattedFilterDate;
    }

    return matchesSeller && matchesDate;
  }).toList();
});

// Provider para órdenes paginadas con filtros
final paginatedFilteredOrdersProvider = Provider<List<Order>>((ref) {
  final filteredOrders = ref.watch(filteredOrdersProvider);
  final orderState = ref.watch(orderProvider);

  final start = (orderState.currentPage - 1) * orderState.itemsPerPage;
  final end = start + orderState.itemsPerPage;

  return filteredOrders.sublist(
    start,
    end > filteredOrders.length ? filteredOrders.length : end,
  );
});

// Provider para total de páginas con filtros
final totalPagesProvider = Provider<int>((ref) {
  final filteredOrders = ref.watch(filteredOrdersProvider);
  final orderState = ref.watch(orderProvider);
  return (filteredOrders.length / orderState.itemsPerPage).ceil();
});
