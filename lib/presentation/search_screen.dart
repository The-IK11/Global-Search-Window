import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSuggestions);
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterSuggestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
        _showSuggestions = false;
      } else {
        _filteredSuggestions = _allSuggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query))
            .toList();
        _showSuggestions = true;
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for: $query')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          setState(() {
            _showSuggestions = false;
          });
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchField(),
              ),
              if (_showSuggestions && _filteredSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredSuggestions.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final suggestion = _filteredSuggestions[index];
                      final query = _searchController.text.toLowerCase();
                      final queryIndex = suggestion.toLowerCase().indexOf(query);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectSuggestion(suggestion),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        if (queryIndex > 0)
                                          TextSpan(
                                            text: suggestion.substring(0, queryIndex),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        TextSpan(
                                          text: _searchController.text,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (queryIndex + _searchController.text.length <
                                            suggestion.length)
                                          TextSpan(
                                            text: suggestion.substring(
                                              queryIndex + _searchController.text.length,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              if (_searchController.text.isNotEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Result for: "${_searchController.text}"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Found ${_filteredSuggestions.length} matching results',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      onSubmitted: (_) => _performSearch(),
      decoration: InputDecoration(
        hintText: 'Search here...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _showSuggestions = false;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }
}