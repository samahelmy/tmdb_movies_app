import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'service/tmdb_service.dart';
import 'bloc/movie_bloc.dart';
import 'Screens/movie_home_screen.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieBloc(tmdbService: TmdbService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movie App ITI',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        home: const MovieHomeScreen(),
      ),
    );
  }
}