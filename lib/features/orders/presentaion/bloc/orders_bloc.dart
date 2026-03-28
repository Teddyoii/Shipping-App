import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../../data/repositories/orders_repository_impl.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository ordersRepository;

  OrdersBloc({required this.ordersRepository}) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
    on<AddOrderRemark>(_onAddOrderRemark);
    on<ExportOrdersToExcel>(_onExportOrdersToExcel);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await ordersRepository.getAllOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: 'Failed to load orders'));
    }
  }

  Future<void> _onFilterOrdersByStatus(FilterOrdersByStatus event, Emitter<OrdersState> emit) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(orders: currentState.orders, selectedStatus: event.status));
    }
  }

  Future<void> _onAddOrderRemark(AddOrderRemark event, Emitter<OrdersState> emit) async {
    try {
      await ordersRepository.addRemark(orderId: event.orderId, remark: event.remark);
      emit(OrderRemarkAdded(orderId: event.orderId));
      final orders = await ordersRepository.getAllOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: 'Failed to add remark'));
    }
  }

  Future<void> _onExportOrdersToExcel(ExportOrdersToExcel event, Emitter<OrdersState> emit) async {
    try {
      final filePath = await ordersRepository.exportToExcel(event.orders);
      emit(OrdersExported(filePath: filePath));
      if (state is OrdersLoaded) {
        final currentState = state as OrdersLoaded;
        emit(OrdersLoaded(orders: currentState.orders, selectedStatus: currentState.selectedStatus));
      }
    } catch (e) {
      emit(OrdersError(message: 'Failed to export orders'));
    }
  }
}