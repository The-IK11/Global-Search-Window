import 'package:flutter/material.dart';
import 'widget/search_window_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Sample data for suggestions
  final List<String> _allSuggestions = [
    'Flutter',
    'Dart',
    'Search Widget',
    'Material Design',
    'Cupertino Design',
    'Firebase',
    'State Management',
    'Provider',
    'Riverpod',
    'Bloc',
    'GetX',
    'Animation',
    'Navigation',
    'REST API',
    'GraphQL',
    'Database',
    'SQLite',
    'Hive',
    'Networking',
    'Image Processing',
  ];

  void _handleSearch(String query) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  void _handleSuggestionSelected(String suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $suggestion')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchWindowWidget(
                suggestions: _allSuggestions,
                onSearchSubmitted: _handleSearch,
                onSuggestionSelected: _handleSuggestionSelected,
              ),
            ),
            Container(
              height: 500,
              width: double.infinity,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}