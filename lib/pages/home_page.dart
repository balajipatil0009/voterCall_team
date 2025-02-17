import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/problem_card.dart';
import 'problem_detail_page.dart';
import 'login_page.dart'; // For logout
import '../themes/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _problems = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
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
    return Theme(
      data: AppTheme.lightBlueTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Problems',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await SupabaseService.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
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
                  child: CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(16.0),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceColor,
                        style: const TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.accentColor,
                        ),
                        underline: Container(
                          height: 2,
                          color: AppTheme.accentColor,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _loadProblems();
                            });
                          }
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'all'
                                  ? 'All Categories'
                                  : value.toUpperCase(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: _problems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppTheme.subtitleColor,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No problems found.",
                                    style: TextStyle(
                                      color: AppTheme.subtitleColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                          problemId: problem['id'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
