import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/movie.dart';

class MovieListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  String get _userId => _auth.currentUser?.uid ?? 'guest_user';


  CollectionReference _getUserListCollection(String listType) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(listType);
  }


  Future<void> addMovie(String listType, Movie movie) async {
    await _getUserListCollection(listType)
        .doc(movie.id.toString())
        .set(movie.toMap());
  }

  
  Future<void> removeMovie(String listType, int movieId) async {
    await _getUserListCollection(listType)
        .doc(movieId.toString())
        .delete();
  }

  
  Future<bool> isMovieInList(String listType, int movieId) async {
    final doc = await _getUserListCollection(listType)
        .doc(movieId.toString())
        .get();
    return doc.exists;
  }


  Stream<List<Movie>> getListStream(String listType) {
    return _getUserListCollection(listType).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}