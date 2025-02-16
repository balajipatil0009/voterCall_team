import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/problem_card.dart';
import 'problem_detail_page.dart';
import 'login_page.dart'; // For logout

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _problems = [];
  bool _isLoading = true;
  String _selectedCategory = 'all'; // Default filter
  final List<String> _categories = [
    'all',
    'education',
    'medical',
    'police',
    'personal'
  ];

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  Future<void> _loadProblems() async {
    setState(() {
      _isLoading = true;
    });
    _problems =
        await SupabaseService.getVoterIssues(category: _selectedCategory);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problems'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          _loadProblems(); // Reload problems with new filter
                        });
                      }
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'all'
                            ? 'All Categories'
                            : value.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _problems.isEmpty
                      ? const Center(child: Text("No problems found."))
                      : ListView.builder(
                          itemCount: _problems.length,
                          itemBuilder: (context, index) {
                            final problem = _problems[index];
                            return ProblemCard(
                              problem: problem,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProblemDetailPage(
                                            problemId:
                                                problem['id'].toString())));
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
