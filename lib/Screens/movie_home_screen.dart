import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../model/movie.dart';
import '../service/auth_service.dart';
import 'login_screen.dart';
import 'movie_detail_screen.dart';
import 'movie_search_screen.dart';
import 'my_lists_screen.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MovieBloc>();
    if (bloc.state is! MovieLoadedState) {
      bloc.add(FetchHomeMoviesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
        title: const Text(
          'TMDB MOVIES',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, color: Colors.amber, size: 26),
            tooltip: 'My Lists',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            tooltip: 'Search Movies',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieSearchScreen()),
              );
              if (mounted) {
                final bloc = context.read<MovieBloc>();
                if (bloc.state is! MovieLoadedState) {
                  bloc.add(FetchHomeMoviesEvent());
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (state is MovieLoadedState) {
            final featuredMovie = state.popularMovies.isNotEmpty ? state.popularMovies.first : null;

            return RefreshIndicator(
              color: Colors.amber,
              backgroundColor: const Color(0xFF1E1E24),
              onRefresh: () async {
                context.read<MovieBloc>().add(FetchHomeMoviesEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (featuredMovie != null) _buildFeaturedHeroBanner(featuredMovie),
                    const SizedBox(height: 12),
                    _buildSectionHeader('Trending Now 🔥'),
                    _buildMovieHorizontalList(state.popularMovies),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Top Rated ⭐'),
                    _buildMovieHorizontalList(state.topRatedMovies),
                    const SizedBox(height: 24),
                    _buildSectionHeader('In Theaters 🎬'),
                    _buildMovieHorizontalList(state.nowPlayingMovies),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Upcoming Releases 🚀'),
                    _buildMovieHorizontalList(state.upcomingMovies),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          } else if (state is MovieErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 55),
                  const SizedBox(height: 14),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () {
                      context.read<MovieBloc>().add(FetchHomeMoviesEvent());
                    },
                    child: const Text('Try Again', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        },
      ),
    );
  }

  Widget _buildFeaturedHeroBanner(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, rect.height * 0.45, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: CachedNetworkImage(
              imageUrl: movie.fullPosterPath,
              height: 480,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 480, color: const Color(0xFF1E1E24)),
              errorWidget: (_, __, ___) => Container(height: 480, color: const Color(0xFF1E1E24)),
            ),
          ),
          Container(
            height: 480,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x99101014),
                  Color(0xFF101014),
                ],
                stops: [0.5, 0.8, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FEATURED SPOTLIGHT',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      movie.releaseDate.split('-').first,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMovieHorizontalList(List<Movie> movies) {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: movie.fullPosterPath,
                            height: 185,
                            width: 130,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 185,
                              width: 130,
                              color: const Color(0xFF1E1E24),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 185,
                              width: 130,
                              color: const Color(0xFF1E1E24),
                              child: const Icon(Icons.broken_image, color: Colors.white24),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}