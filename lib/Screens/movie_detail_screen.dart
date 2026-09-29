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
    try {
      final results = await Future.wait([
        _listService.isMovieInList('favorites', widget.movie.id),
        _listService.isMovieInList('watching', widget.movie.id),
        _listService.isMovieInList('watched', widget.movie.id),
        _listService.isMovieInList('want_to_watch', widget.movie.id),
      ]);

      if (mounted) {
        setState(() {
          isFavorite = results[0];
          isWatching = results[1];
          isWatched = results[2];
          isWantToWatch = results[3];
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleList(String listType, bool currentStatus) async {
    // Instant optimistic update
    setState(() {
      if (listType == 'favorites') isFavorite = !isFavorite;
      if (listType == 'watching') isWatching = !isWatching;
      if (listType == 'watched') isWatched = !isWatched;
      if (listType == 'want_to_watch') isWantToWatch = !isWantToWatch;
    });

    try {
      if (currentStatus) {
        await _listService.removeMovie(listType, widget.movie.id);
        _showToast('Removed from list successfully');
      } else {
        await _listService.addMovie(listType, widget.movie);
        _showToast('Added to list successfully');
      }
    } catch (e) {
      _checkInitialStatus();
      _showToast('Failed to update: $e');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1E26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF141419),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.movie.backdropPath.isNotEmpty
                        ? widget.movie.fullBackdropPath
                        : widget.movie.fullPosterPath,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.black26),
                    errorWidget: (_, __, ___) => Container(color: Colors.black26),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0F0F12).withOpacity(0.5),
                          const Color(0xFF0F0F12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        widget.movie.releaseDate.isNotEmpty ? widget.movie.releaseDate : 'N/A',
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Manage Lists',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isLoading)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _buildActionButton(
                          label: 'Favorite',
                          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                          isActive: isFavorite,
                          activeColor: Colors.redAccent,
                          onTap: () => _toggleList('favorites', isFavorite),
                        ),
                        _buildActionButton(
                          label: 'Watching',
                          icon: isWatching ? Icons.play_circle : Icons.play_circle_outline,
                          isActive: isWatching,
                          activeColor: Colors.cyanAccent,
                          onTap: () => _toggleList('watching', isWatching),
                        ),
                        _buildActionButton(
                          label: 'Watched',
                          icon: isWatched ? Icons.check_circle : Icons.check_circle_outline,
                          isActive: isWatched,
                          activeColor: Colors.greenAccent,
                          onTap: () => _toggleList('watched', isWatched),
                        ),
                        _buildActionButton(
                          label: 'Plan to Watch',
                          icon: isWantToWatch ? Icons.bookmark : Icons.bookmark_outline,
                          isActive: isWantToWatch,
                          activeColor: Colors.amber,
                          onTap: () => _toggleList('want_to_watch', isWantToWatch),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'No overview available for this movie.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.18) : const Color(0xFF1B1B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : Colors.white24,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : Colors.white70,
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}