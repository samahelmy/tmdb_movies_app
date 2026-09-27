import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/tmdb_service.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final TmdbService tmdbService;

  MovieBloc({required this.tmdbService}) : super(MovieInitialState()) {
    
    on<FetchHomeMoviesEvent>((event, emit) async {
      emit(MovieLoadingState());
      try {
        final popular = await tmdbService.getPopularMovies();
        final topRated = await tmdbService.getTopRatedMovies();
        final nowPlaying = await tmdbService.getNowPlayingMovies();
        final upcoming = await tmdbService.getUpcomingMovies();

        emit(MovieLoadedState(
          popularMovies: popular,
          topRatedMovies: topRated,
          nowPlayingMovies: nowPlaying,
          upcomingMovies: upcoming,
        ));
      } catch (e) {
        emit(MovieErrorState(e.toString()));
      }
    });

    
    on<SearchMoviesEvent>((event, emit) async {
      if (event.query.trim().isEmpty) {
        add(FetchHomeMoviesEvent());
        return;
      }
      emit(MovieLoadingState());
      try {
        final results = await tmdbService.searchMovies(event.query);
        emit(MovieSearchLoadedState(results));
      } catch (e) {
        emit(MovieErrorState(e.toString()));
      }
    });
  }
}