import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/google_books_service.dart';
import '../services/library_service.dart';
import 'book_details_screen.dart';
import '../global_wrapper.dart';

class SearchScreen extends StatefulWidget {
  final LibraryService libraryService;

  const SearchScreen({super.key, required this.libraryService});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Book> _currentPageResults = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _maxResultsPerPage = 20;
  bool _hasMoreResults = true;
  final int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  Future<void> _performSearch({int page = 1, bool newSearch = false}) async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
        if (newSearch) {
          _currentPageResults = [];
          _currentPage = 1;
          _hasMoreResults = true;
        }
      });
      try {
        final encodedQuery = Uri.encodeQueryComponent(query);
        final results = await _booksService.searchBooks(
          encodedQuery,
          page: page,
          maxResults: _maxResultsPerPage,
        );

        final filteredResults =
            results.where((book) => book.thumbnailUrl.isNotEmpty).toList();

        setState(() {
          _currentPageResults = filteredResults;
          _isLoading = false;
          _currentPage = page;
          _hasMoreResults = results.length == _maxResultsPerPage;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  void _nextPage() {
    if (!_isLoading && _hasMoreResults) {
      _performSearch(page: _currentPage + 1);
    }
  }

  void _previousPage() {
    if (!_isLoading && _currentPage > 1) {
      _performSearch(page: _currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackButtonHandler(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesquisar Livros'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Digite o título do livro ou autor',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _currentPageResults = [];
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onSubmitted: (_) => _performSearch(newSearch: true),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentPageResults.isEmpty
                        ? const Center(
                            child: Text('Nenhum resultado encontrado'))
                        : ListView.builder(
                            itemCount: _currentPageResults.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _currentPageResults.length) {
                                return _buildPaginationControls();
                              }
                              final book = _currentPageResults[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      book.thumbnailUrl,
                                      width: 50,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    book.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(book.authors.join(', ')),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailsScreen(
                                          book: book,
                                          libraryService: widget.libraryService,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          libraryService: widget.libraryService,
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1 ? _previousPage : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Anterior'),
          ),
          const SizedBox(width: 16),
          Text('Página $_currentPage'),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _hasMoreResults ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Próxima'),
          ),
        ],
      ),
    );
  }
}
