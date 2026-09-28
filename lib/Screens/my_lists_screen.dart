import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/movie.dart';
import '../service/movie_list_service.dart';
import 'movie_detail_screen.dart';

class MyListsScreen extends StatelessWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
           "My Lists",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
              Tab(icon: Icon(Icons.play_circle_fill), text: 'Watching'),
              Tab(icon: Icon(Icons.check_circle), text: 'Watched'),
              Tab(icon: Icon(Icons.bookmark), text: 'Want to Watch'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MovieCategoryList(listType: 'favorites', emptyMsg: "No Films Yet"),
            _MovieCategoryList(listType: 'watching', emptyMsg: "No Films Yet"),
            _MovieCategoryList(listType: 'watched', emptyMsg: "No Films Yet"),
            _MovieCategoryList(listType: 'want_to_watch', emptyMsg: "No Films Yet"),
          ],
        ),
      ),
    );
  }
}

class _MovieCategoryList extends StatelessWidget {
  final String listType;
  final String emptyMsg;

  const _MovieCategoryList({
    required this.listType,
    required this.emptyMsg,
  });

  @override
  Widget build(BuildContext context) {
    final listService = MovieListService();

    return StreamBuilder<List<Movie>>(
      stream: listService.getListStream(listType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_filter_outlined, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text(
                  emptyMsg,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white12),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: movie.fullPosterPath,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[900]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.movie, color: Colors.white24),
                  ),
                ),
              ),
              title: Text(
                movie.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  await listService.removeMovie(listType, movie.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Removed from List"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}