import '../model/movie.dart';

abstract class MovieState {}

class MovieInitialState extends MovieState {}

class MovieLoadingState extends MovieState {}

class MovieLoadedState extends MovieState {
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;
  final List<Movie> nowPlayingMovies;
  final List<Movie> upcomingMovies;

  MovieLoadedState({
    required this.popularMovies,
    required this.topRatedMovies,
    required this.nowPlayingMovies,
    required this.upcomingMovies,
  });
}

class MovieSearchLoadedState extends MovieState {
  final List<Movie> searchResults;
  MovieSearchLoadedState(this.searchResults);
}

class MovieErrorState extends MovieState {
  final String message;
  MovieErrorState(this.message);
}