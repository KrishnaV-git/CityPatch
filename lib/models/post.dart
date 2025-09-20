import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String imageUrl;
  final String uid;
  final String username;
  final int severity;
  final String note;
  final Timestamp timestamp;
  final double lat;
  final double lng;
  final String locationText;
  final List<dynamic> upvotes;

  PostModel({
    required this.id,
    required this.imageUrl,
    required this.uid,
    required this.username,
    required this.severity,
    required this.note,
    required this.timestamp,
    required this.lat,
    required this.lng,
    required this.locationText,
    required this.upvotes,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      imageUrl: d['imageUrl'] ?? '',
      uid: d['uid'] ?? '',
      username: d['username'] ?? '',
      severity: (d['severity'] ?? 1) as int,
      note: d['note'] ?? '',
      timestamp: d['timestamp'] ?? Timestamp.now(),
      lat: (d['location']?['lat'] ?? 0.0) + 0.0,
      lng: (d['location']?['lng'] ?? 0.0) + 0.0,
      locationText: d['locationText'] ?? '',
      upvotes: List.from(d['upvotes'] ?? []),
    );
  }
}
