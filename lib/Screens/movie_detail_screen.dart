import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/movie.dart';
import '../service/movie_list_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieListService _listService = MovieListService();

  
  bool isFavorite = false;
  bool isWatching = false;
  bool isWatched = false;
  bool isWantToWatch = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final fav = await _listService.isMovieInList('favorites', widget.movie.id);
    final watching = await _listService.isMovieInList('watching', widget.movie.id);
    final watched = await _listService.isMovieInList('watched', widget.movie.id);
    final want = await _listService.isMovieInList('want_to_watch', widget.movie.id);

    if (mounted) {
      setState(() {
        isFavorite = fav;
        isWatching = watching;
        isWatched = watched;
        isWantToWatch = want;
        isLoading = false;
      });
    }
  }

  Future<void> _toggleList(String listType, bool currentStatus) async {
    try {
      if (currentStatus) {
        await _listService.removeMovie(listType, widget.movie.id);
        _showToast("Removed from List");
      } else {
        await _listService.addMovie(listType, widget.movie);
        _showToast("Added to List");
      }
      _checkInitialStatus();
    } catch (e) {
      _showToast('Error $e');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey[850],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E1E),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.movie.backdropPath.isNotEmpty
                        ? widget.movie.fullBackdropPath
                        : widget.movie.fullPosterPath,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[900]),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF121212)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.movie.releaseDate.isNotEmpty ? widget.movie.releaseDate : 'N/A',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                   "My Lists",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.amber))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Favorites',
                          icon: Icons.favorite,
                          isActive: isFavorite,
                          activeColor: Colors.redAccent,
                          onSelected: () => _toggleList('favorites', isFavorite),
                        ),
                        _buildFilterChip(
                          label: 'Watching',
                          icon: Icons.play_circle_fill,
                          isActive: isWatching,
                          activeColor: Colors.blueAccent,
                          onSelected: () => _toggleList('watching', isWatching),
                        ),
                        _buildFilterChip(
                          label: 'Watched',
                          icon: Icons.check_circle,
                          isActive: isWatched,
                          activeColor: Colors.green,
                          onSelected: () => _toggleList('watched', isWatched),
                        ),
                        _buildFilterChip(
                          label: 'Want to Watch',
                          icon: Icons.bookmark,
                          isActive: isWantToWatch,
                          activeColor: Colors.orangeAccent,
                          onSelected: () => _toggleList('want_to_watch', isWantToWatch),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty ? widget.movie.overview : 'لا يوجد وصف متاح لهذا الفيلم.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      avatar: Icon(
        icon,
        color: isActive ? Colors.white : activeColor,
        size: 18,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedColor: activeColor,
      backgroundColor: const Color(0xFF1E1E1E),
      side: BorderSide(color: activeColor.withOpacity(0.5)),
      onSelected: (_) => onSelected(),
    );
  }
}