import 'package:flutter/material.dart';

import '../global_wrapper.dart';
import '../models/book.dart';
import '../services/google_books_service.dart';
import '../services/library_service.dart';
import 'book_details_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  final LibraryService libraryService;

  const MainScreen({super.key, required this.libraryService});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final int _currentIndex = 0;
  final Map<String, List<Book>> _genreBooks = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGenreBooks();
  }

  void _loadGenreBooks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, String> genreTranslations = {
        'Self-help': 'Autoajuda',
        'Science': 'Ciência',
        'Education': 'Educação',
        'Fantasy': 'Fantasia',
        'Fiction': 'Ficção',
        'History': 'História',
        'Romance': 'Romance',
        'Suspense': 'Suspense',
        'Horror': 'Terror',
      };
      for (var genreInEnglish in genreTranslations.keys) {
        final books =
            await _booksService.searchBooks(genreInEnglish, maxResults: 8);

        final filteredBooks =
            books.where((book) => book.thumbnailUrl.isNotEmpty).toList();

        setState(() {
          _genreBooks[genreTranslations[genreInEnglish]!] = filteredBooks;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading genre books: ${e.toString()}')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Codexia'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.deepPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    libraryService: widget.libraryService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          LibraryScreen(libraryService: widget.libraryService),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        libraryService: widget.libraryService,
      ),
    );
  }

  Widget _buildHomeTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: _buildGenreSuggestions(),
              ),
            ],
          );
  }

  Widget _buildGenreSuggestions() {
    return ListView.builder(
      itemCount: _genreBooks.length,
      itemBuilder: (context, index) {
        final genre = _genreBooks.keys.elementAt(index);
        final books = _genreBooks[genre] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 12.0),
              child: Text(
                genre,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, bookIndex) {
                  return _buildBookCard(books[bookIndex]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
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
      child: Card(
        margin: const EdgeInsets.only(left: 10.0, right: 8.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              book.thumbnailUrl,
              height: 135,
              width: 105,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
