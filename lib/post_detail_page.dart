import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final Map<String, Object> report;
  const PostDetailPage({super.key, required this.postId, required this.report});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentCtrl = TextEditingController();
  final postsRef = FirebaseFirestore.instance.collection('posts');

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login to comment')));
      return;
    }
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final commentsRef = postsRef.doc(widget.postId).collection('comments');
    await commentsRef.add({
      'authorUid': user.uid,
      'authorName': user.displayName ?? user.email?.split('@').first ?? 'Anonymous',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentCtrl.clear();
  }

  Future<void> _toggleUpvote(List upvotes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login to upvote')));
      return;
    }
    final ref = postsRef.doc(widget.postId);
    final snap = await ref.get();
    final data = snap.data();
    final current = List<String>.from(data?['upvotes'] ?? []);
    if (current.contains(user.uid)) {
      current.remove(user.uid);
    } else {
      current.add(user.uid);
    }
    await ref.update({'upvotes': current});
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: postsRef.doc(widget.postId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            );
          }
          
          final data = snap.data!.data() as Map<String, dynamic>;
          final imageUrl = data['imageUrl'] ?? '';
          final username = data['username'] ?? 'Anonymous';
          final severity = data['severity'] ?? 1;
          final note = data['note'] ?? '';
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          final timeText = timestamp != null ? DateFormat.yMMMd().add_jm().format(timestamp) : '';
          final upvotes = List.from(data['upvotes'] ?? []);

          return Column(
            children: [
              // Image section
              if (imageUrl.isNotEmpty)
                Container(
                  height: 250,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Content section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Report details card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User info
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.indigo.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.indigo.shade900,
                                        ),
                                      ),
                                      Text(
                                        timeText,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Upvote button
                                GestureDetector(
                                  onTap: () => _toggleUpvote(upvotes),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: upvotes.contains(currentUser?.uid)
                                          ? Colors.indigo.shade50
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: upvotes.contains(currentUser?.uid)
                                            ? Colors.indigo.shade200
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          upvotes.contains(currentUser?.uid)
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          size: 16,
                                          color: upvotes.contains(currentUser?.uid)
                                              ? Colors.indigo.shade600
                                              : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${upvotes.length}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: upvotes.contains(currentUser?.uid)
                                                ? Colors.indigo.shade700
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Severity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(severity).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getSeverityColor(severity).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: _getSeverityColor(severity),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Severity $severity - ${_getSeverityText(severity)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getSeverityColor(severity),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Note
                            Text(
                              note,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Comments section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  color: Colors.indigo.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Comments',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Comments list
                            StreamBuilder<QuerySnapshot>(
                              stream: postsRef.doc(widget.postId).collection('comments')
                                  .orderBy('timestamp', descending: false).snapshots(),
                              builder: (context, csnap) {
                                if (!csnap.hasData) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                final docs = csnap.data!.docs;
                                if (docs.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.comment_outlined,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No comments yet',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: docs.length,
                                  itemBuilder: (context, i) {
                                    final d = docs[i].data() as Map<String, dynamic>;
                                    final author = d['authorName'] ?? 'Anonymous';
                                    final text = d['text'] ?? '';
                                    final ts = (d['timestamp'] as Timestamp?)?.toDate();
                                    final time = ts != null ? DateFormat.yMMMd().add_jm().format(ts) : '';
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.indigo.shade100,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 12,
                                                  color: Colors.indigo.shade600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                author,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.indigo.shade900,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                time,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            text,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for comment input
                    ],
                  ),
                ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.indigo, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _addComment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1:
        return 'Minor';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}
