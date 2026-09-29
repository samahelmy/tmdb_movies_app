import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../model/movie.dart';
import 'movie_detail_screen.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final trimmed = query.trim();
      if (trimmed.isNotEmpty) {
        context.read<MovieBloc>().add(SearchMoviesEvent(trimmed));
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.amber,
          decoration: const InputDecoration(
            hintText: 'Search for movies...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        buildWhen: (previous, current) {
          // عزل شاشة البحث بحيث لا تتأثر بحالات شاشة الهوم
          return current is MovieSearchLoadedState ||
              current is MovieLoadingState ||
              current is MovieErrorState;
        },
        builder: (context, state) {
          if (state is MovieLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (state is MovieSearchLoadedState) {
            final movies = state.searchResults;

            if (movies.isEmpty) {
              return const Center(
                child: Text(
                  'No movies found matching your search.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie.fullPosterPath.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: movie.fullPosterPath,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: Colors.black26),
                              errorWidget: (_, __, ___) => Container(
                                width: 50,
                                height: 75,
                                color: Colors.white10,
                                child: const Icon(Icons.movie, color: Colors.white38),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 75,
                              color: Colors.white10,
                              child: const Icon(Icons.movie, color: Colors.white38),
                            ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            movie.releaseDate.isNotEmpty ? movie.releaseDate : 'N/A',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is MovieErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.white24),
                SizedBox(height: 12),
                Text(
                  'Search for your favorite movies',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}