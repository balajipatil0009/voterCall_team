import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Problem Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _problemDetails == null
              ? const Center(child: Text("Error loading problem details."))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${_problemDetails!['category'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                          'Description: ${_problemDetails!['description'] ?? 'No Description'}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Text('Status: ${_problemDetails!['status'] ?? 'pending'}',
                          style: const TextStyle(fontSize: 16)),
                      if (_problemDetails!['solver'] != null)
                        Text(
                            'Solver ID: ${_problemDetails!['solver'].toString()}', // Modified line
                            style: const TextStyle(fontSize: 16)),
                      const Spacer(), // Push buttons to bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_problemDetails!['status'] == 'pending')
                            ElevatedButton(
                              onPressed: _setProblemToProcessing,
                              child: const Text('Solve'),
                            ),
                          if (_problemDetails!['status'] == 'processing' &&
                              _problemDetails!['solver'] == _currentUserId)
                            ElevatedButton(
                              onPressed: _setProblemToDone,
                              child: const Text('Solved'),
                            ),
                          if (_problemDetails!['status'] == 'processing' &&
                              _problemDetails!['solver'] == _currentUserId)
                            ElevatedButton(
                              onPressed: _setProblemToPending,
                              child: const Text('Leave'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange), // Example styling
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
