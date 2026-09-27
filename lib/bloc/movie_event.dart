abstract class MovieEvent {}


class FetchHomeMoviesEvent extends MovieEvent {}


class SearchMoviesEvent extends MovieEvent {
  final String query;
  SearchMoviesEvent(this.query);
}