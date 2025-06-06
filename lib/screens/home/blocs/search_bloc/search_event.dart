part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchPizzas extends SearchEvent {
  final String query;

  const SearchPizzas({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {}
