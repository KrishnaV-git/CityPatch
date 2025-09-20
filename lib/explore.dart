import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import 'package:potholedetect/login_page.dart';
import 'package:potholedetect/post_detail_page.dart';
import 'package:potholedetect/report_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final random = Random();
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likeCounts = {};

  final sampleReports = [
    {
      "id": "report_1",
      "username": "John Doe",
      "note": "Huge pothole near the main road, very dangerous!",
      "severity": 5,
      "location": "MG Road, Bangalore",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
      "image": "lib/images/pothole1.jpeg",
      "comments": [
        {"author": "Sarah Wilson", "text": "I saw this too! It's really dangerous for cyclists.", "time": "2h ago"},
        {"author": "Mike Chen", "text": "Reported this to the local authorities last week.", "time": "1h ago"},
        {"author": "Priya Singh", "text": "Thanks for reporting! This needs immediate attention.", "time": "30m ago"},
      ]
    },
    {
      "id": "report_2",
      "username": "Aditi Sharma",
      "note": "Small pothole but getting worse after rains.",
      "severity": 3,
      "location": "Park Street, Kolkata",
      "time": DateTime.now().subtract(const Duration(days: 1)),
      "image": "lib/images/pothole2.jpeg",
      "comments": [
        {"author": "Raj Patel", "text": "I've been avoiding this route because of this pothole.", "time": "1d ago"},
        {"author": "Lisa Johnson", "text": "The monsoon made it much worse this year.", "time": "20h ago"},
      ]
    },
    {
      "id": "report_3",
      "username": "Ravi Kumar",
      "note": "Road almost broken, vehicles struggling to pass.",
      "severity": 4,
      "location": "Outer Ring Road, Hyderabad",
      "time": DateTime.now().subtract(const Duration(minutes: 45)),
      "image": "lib/images/pothole3.jpeg",
      "comments": [
        {"author": "David Brown", "text": "This is a major safety hazard!", "time": "40m ago"},
        {"author": "Anita Reddy", "text": "I'll share this with the traffic police.", "time": "35m ago"},
        {"author": "Tom Wilson", "text": "Hope they fix this soon before someone gets hurt.", "time": "30m ago"},
        {"author": "Sneha Gupta", "text": "I've seen multiple accidents here recently.", "time": "25m ago"},
      ]
    },
  ];

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  void _toggleLike(String postId) {
    setState(() {
      _likedPosts[postId] = !(_likedPosts[postId] ?? false);
      _likeCounts[postId] = (_likeCounts[postId] ?? 12) + (_likedPosts[postId]! ? 1 : -1);
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _likedPosts[postId]! ? 'Liked!' : 'Unliked',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _likedPosts[postId]! ? Colors.green : Colors.grey.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showRandomComments(Map<String, dynamic> report) {
    final comments = report['comments'] as List<dynamic>? ?? [];
    if (comments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No comments available for this post'),
          backgroundColor: Colors.grey.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _showCommentsModal(report, comments);
  }

  void _showCommentsModal(Map<String, dynamic> report, List<dynamic> comments) {
    // Shuffle comments to show random ones
    final shuffledComments = List.from(comments)..shuffle();
    final randomComments = shuffledComments.take(3).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.comment,
                    color: Colors.indigo.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Comments',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${comments.length} total',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCommentsModal(report, comments);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.indigo.shade600,
                      size: 20,
                    ),
                    tooltip: 'Refresh comments',
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Comments list
            Expanded(
              child: randomComments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments to show',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try refreshing to see different comments',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: randomComments.length,
                      itemBuilder: (context, index) {
                  final comment = randomComments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.indigo.shade100,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.indigo.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              comment['author'] ?? 'Anonymous',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              comment['time'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          comment['text'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLiked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLiked ? Colors.indigo.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLiked ? Colors.indigo.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isLiked ? Colors.indigo.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isLiked ? Colors.indigo.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Pothole Reports",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.indigo.shade600),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return const LoginPage();
              }), (route) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.report_problem,
                    color: Colors.indigo.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Community Reports",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                      Text(
                        "Help improve road conditions by reporting potholes",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Reports list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sampleReports.length,
              itemBuilder: (context, index) {
                final report = sampleReports[index];
                final severity = report["severity"] as int;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                      // Image
                      if (report["image"] != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            report["image"].toString(),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User + Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.indigo.shade100,
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.indigo.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      report["username"].toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatTime(report["time"] as DateTime),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Severity Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: severity >= 4
                                    ? Colors.red.shade50
                                    : (severity == 3
                                        ? Colors.orange.shade50
                                        : Colors.green.shade50),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: severity >= 4
                                      ? Colors.red.shade200
                                      : (severity == 3
                                          ? Colors.orange.shade200
                                          : Colors.green.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: severity >= 4
                                        ? Colors.red.shade600
                                        : (severity == 3
                                            ? Colors.orange.shade600
                                            : Colors.green.shade600),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Severity $severity",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: severity >= 4
                                          ? Colors.red.shade700
                                          : (severity == 3
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Note
                            Text(
                              report["note"].toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.indigo.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    report["location"].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action buttons
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: (_likedPosts[report['id']] ?? false) 
                                      ? Icons.thumb_up 
                                      : Icons.thumb_up_outlined,
                                  label: "${_likeCounts[report['id']] ?? 12}",
                                  onTap: () => _toggleLike(report['id'] as String),
                                  isLiked: _likedPosts[report['id']] ?? false,
                                ),
                                const SizedBox(width: 24),
                                _buildActionButton(
                                  icon: Icons.comment_outlined,
                                  label: "${(report['comments'] as List?)?.length ?? 0}",
                                  onTap: () => _showRandomComments(report),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostDetailPage(
                                          report: report,
                                          postId: (report['id'] as String?) ?? 'sample_$index',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "View Details",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportPage(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Report Pothole",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}