import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:cart_repository/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  StreamSubscription<List<CartItem>>? _cartSubscription;
  
  CartBloc({required CartRepository cartRepository}) 
      : _cartRepository = cartRepository,
        super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
    on<CartUpdated>(_onCartUpdated);
    on<RefreshCart>(_onRefreshCart);
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }  void _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    await _cartSubscription?.cancel();
    _cartSubscription = _cartRepository.getCartItems(event.userId).listen(
      (cartItems) => add(CartUpdated(items: cartItems)),
    );
  }

  void _onCartUpdated(CartUpdated event, Emitter<CartState> emit) {
    emit(CartLoaded(items: event.items));
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      final cartItem = CartItem(
        userId: event.userId,
        pizza: event.pizza,
        quantity: event.quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _cartRepository.addToCart(cartItem);
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.removeFromCart(event.userId, event.pizzaId);
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) async {
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final existingItem = currentState.items.firstWhere(
          (item) => item.pizza.pizzaId == event.pizzaId,
        );
        final updatedItem = existingItem.copyWith(
          quantity: event.quantity,
          updatedAt: DateTime.now(),
        );
        await _cartRepository.updateCartItem(updatedItem);
      }
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.clearCart(event.userId);
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  void _onRefreshCart(RefreshCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await _cartSubscription?.cancel();
      _cartSubscription = _cartRepository.getCartItems(event.userId).listen(
        (cartItems) => add(CartUpdated(items: cartItems)),
      );
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }
}
