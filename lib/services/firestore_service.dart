import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final posts = FirebaseFirestore.instance.collection('posts');

  Future<String> uploadImage(File file, String pathPrefix) async {
    final id = const Uuid().v4();
    final ref = FirebaseStorage.instance.ref().child('$pathPrefix/$id.jpg');
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<DocumentReference> createPost({
    required String imageUrl,
    required String uid,
    required String username,
    required int severity,
    required String note,
    required double lat,
    required double lng,
    String locationText = '',
  }) async {
    final doc = await posts.add({
      'imageUrl': imageUrl,
      'uid': uid,
      'username': username,
      'severity': severity,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
      'location': {'lat': lat, 'lng': lng},
      'locationText': locationText,
      'upvotes': [],
    });
    return doc;
  }

  Future<void> toggleUpvote(String postId, String uid) async {
    final ref = posts.doc(postId);
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) return;
    final upvotes = List<String>.from(data['upvotes'] ?? []);
    if (upvotes.contains(uid)) {
      upvotes.remove(uid);
    } else {
      upvotes.add(uid);
    }
    await ref.update({'upvotes': upvotes});
  }

  Stream<QuerySnapshot> postsStream() {
    return posts.orderBy('timestamp', descending: true).snapshots();
  }
}
