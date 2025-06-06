import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final List<Pizza> allPizzas;

  SearchBloc({required this.allPizzas}) : super(SearchInitial()) {
    on<SearchPizzas>((event, emit) {
      emit(SearchLoading());
      
      try {
        if (event.query.isEmpty) {
          emit(SearchInitial());
          return;
        }

        final filteredPizzas = allPizzas.where((pizza) {
          final query = event.query.toLowerCase();
          return pizza.name.toLowerCase().contains(query) ||
                 pizza.description.toLowerCase().contains(query);
        }).toList();

        emit(SearchSuccess(pizzas: filteredPizzas, query: event.query));
      } catch (e) {
        emit(SearchFailure(error: e.toString()));
      }
    });

    on<ClearSearch>((event, emit) {
      emit(SearchInitial());
    });
  }
}
