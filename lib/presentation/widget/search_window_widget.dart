import 'package:flutter/material.dart';

class SearchWindowWidget extends StatefulWidget {
  final List<String> suggestions;
  final Function(String) onSearchSubmitted;
  final Function(String)? onSuggestionSelected;

  const SearchWindowWidget({
    super.key,
    required this.suggestions,
    required this.onSearchSubmitted,
    this.onSuggestionSelected,
  });

  @override
  State<SearchWindowWidget> createState() => _SearchWindowWidgetState();
}

class _SearchWindowWidgetState extends State<SearchWindowWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSuggestions);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _searchController.text.isNotEmpty) {
        _showSuggestionsOverlay();
      } else {
        _hideSuggestionsOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _filterSuggestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
        _hideSuggestionsOverlay();
      } else {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query))
            .toList();
        if (_focusNode.hasFocus) {
          _showSuggestionsOverlay();
        }
      }
    });
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
       top: _getOverlayPosition(),
          left: MediaQuery.of(context).padding.left + 16,
          right: MediaQuery.of(context).padding.right + 16,
          child: Material(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
                _hideSuggestionsOverlay();
              },
              child: _filteredSuggestions.isEmpty
                  ? _buildNoResultsWidget()
                  : _buildSuggestionsDropdown(),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getOverlayPosition() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero).dy + 48;
    }
    return 48;
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _hideSuggestionsOverlay();
    _focusNode.unfocus();
    widget.onSuggestionSelected?.call(suggestion);
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      widget.onSearchSubmitted(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchField();
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
                  _hideSuggestionsOverlay();
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

  Widget _buildNoResultsWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No suggestions match "${_searchController.text}"',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
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
        padding: EdgeInsets.zero,
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
    );
  }

  String getSearchQuery() {
    return _searchController.text;
  }

  void clearSearch() {
    _searchController.clear();
    _hideSuggestionsOverlay();
  }
}
