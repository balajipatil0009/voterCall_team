import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../themes/app_theme.dart';

class ProblemDetailPage extends StatefulWidget {
  final String problemId;

  const ProblemDetailPage({super.key, required this.problemId});

  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}

class _ProblemDetailPageState extends State<ProblemDetailPage> {
  Map<String, dynamic>? _problemDetails;
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProblemDetails();
    _currentUserId = SupabaseService.getCurrentUserId();
  }

  Future<void> _loadProblemDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await SupabaseService.client
          .from('voter_issues')
          .select('*')
          .eq('id', widget.problemId)
          .single();

      if (response is Map) {
        setState(() {
          _problemDetails =
              Map<String, dynamic>.from(response); // Ensure it's a Map
          _isLoading = false;
        });
      } else if (response is PostgrestException) {
        // print('Supabase Error fetching problem details: ${response.message}');
        // Handle error, maybe show an error message on UI
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching problem details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setProblemToProcessing() async {
    if (_problemDetails == null || _currentUserId == null) return;
    setState(() {
      _isLoading = true;
    });
    final success = await SupabaseService.setProblemToProcessing(
        widget.problemId, _currentUserId!);
    if (success) {
      _loadProblemDetails(); // Refresh details to update status and solver
    } else {
      // Handle error (e.g., show snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set problem to processing.')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setProblemToDone() async {
    if (_problemDetails == null) return;
    setState(() {
      _isLoading = true;
    });
    final success = await SupabaseService.setProblemToDone(widget.problemId);
    if (success) {
      _loadProblemDetails(); // Refresh details
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set problem to done.')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setProblemToPending() async {
    if (_problemDetails == null) return;
    setState(() {
      _isLoading = true;
    });
    final success = await SupabaseService.setProblemToPending(widget.problemId);
    if (success) {
      _loadProblemDetails(); // Refresh details
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set problem to pending.')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.subtitleColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'processing':
        chipColor = Colors.blue;
        statusIcon = Icons.running_with_errors;
        break;
      case 'done':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        chipColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: chipColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightBlueTheme,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Problem Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundColor,
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor))
              : _problemDetails == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.subtitleColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Error loading problem details",
                            style: TextStyle(
                              color: AppTheme.subtitleColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadProblemDetails,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusChip(
                              _problemDetails!['status'] ?? 'pending'),
                          const SizedBox(height: 24),
                          _buildInfoSection(
                            'CATEGORY',
                            _problemDetails!['category'] ?? 'N/A',
                          ),
                          _buildInfoSection(
                            'DESCRIPTION',
                            _problemDetails!['description'] ?? 'No Description',
                          ),
                          if (_problemDetails!['solver'] != null)
                            _buildInfoSection(
                              'SOLVER ID',
                              _problemDetails!['solver'].toString(),
                            ),
                          if (_problemDetails!['created_at'] != null)
                            _buildInfoSection(
                              'CREATED AT',
                              DateFormat('MMM d, yyyy hh:mm a').format(
                                  DateTime.parse(
                                      _problemDetails!['created_at'])),
                            ),
                          const SizedBox(height: 32),
                          if (_problemDetails!['status'] == 'pending' ||
                              _problemDetails!['status'] == 'processing')
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_problemDetails!['status'] == 'pending')
                                    ElevatedButton(
                                      onPressed: _setProblemToProcessing,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'SOLVE THIS PROBLEM',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (_problemDetails!['status'] ==
                                          'processing' &&
                                      _problemDetails!['solver'] ==
                                          _currentUserId) ...[
                                    ElevatedButton(
                                      onPressed: _setProblemToDone,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'MARK AS SOLVED',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _setProblemToPending,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: const BorderSide(
                                              color: Colors.orange),
                                        ),
                                      ),
                                      child: const Text(
                                        'LEAVE PROBLEM',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
