import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/movie.dart';

class MovieListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  String get _userId => _auth.currentUser?.uid ?? 'guest_user';


  CollectionReference<Map<String, dynamic>> _collection(String listType) {
    return _firestore.collection('users').doc(_userId).collection(listType);
  }

  
  Future<void> addMovie(String listType, Movie movie) async {
    await _collection(listType).doc(movie.id.toString()).set(movie.toMap());
  }


  Future<void> removeMovie(String listType, int movieId) async {
    await _collection(listType).doc(movieId.toString()).delete();
  }

  
  Future<bool> isMovieInList(String listType, int movieId) async {
    final doc = await _collection(listType).doc(movieId.toString()).get();
    return doc.exists;
  }

  
  Stream<List<Movie>> getListStream(String listType) {
    return _collection(listType).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
    });
  }
}