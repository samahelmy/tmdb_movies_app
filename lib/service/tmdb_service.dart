import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/movie.dart';

class TmdbService {
  
  static const String _apiKey = 'fbddbf9f3ad91c8a39ee97aca229787b';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  
  Future<List<Movie>> getPopularMovies() async {
    return _fetchMovies('$_baseUrl/movie/popular?api_key=$_apiKey');
  }

  
  Future<List<Movie>> getTopRatedMovies() async {
    return _fetchMovies('$_baseUrl/movie/top_rated?api_key=$_apiKey');
  }

  
  Future<List<Movie>> getNowPlayingMovies() async {
    return _fetchMovies('$_baseUrl/movie/now_playing?api_key=$_apiKey');
  }

  
  Future<List<Movie>> getUpcomingMovies() async {
    return _fetchMovies('$_baseUrl/movie/upcoming?api_key=$_apiKey');
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final url = '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}';
    return _fetchMovies(url);
  }

  
  Future<List<Movie>> _fetchMovies(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Movie.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network or API Error: $e');
    }
  }
}