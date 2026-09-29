import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/movie.dart';

class TmdbService {
  static const String _apiKey = "fbddbf9f3ad91c8a39ee97aca229787b";
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  
  Future<List<Movie>> searchMovies(String query) async {
    final cleanQuery = Uri.encodeComponent(query.trim());
    final url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$cleanQuery&language=en-US&page=1');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  // الدوال الأخرى المعتادة (Popular, Top Rated, Now Playing)
  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Failed to load popular movies');
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Failed to load top rated movies');
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Failed to load now playing movies');
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&language=en-US&page=1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Failed to load upcoming movies');
  }
}