import 'package:flutter/material.dart';

import '../global_wrapper.dart';
import '../models/book.dart';
import '../services/library_service.dart';
import 'book_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  final LibraryService libraryService;

  const LibraryScreen({super.key, required this.libraryService});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _booksFuture = widget.libraryService.getAllBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackButtonHandler(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minha Biblioteca'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _loadBooks();
          },
          child: FutureBuilder<List<Book>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Erro ao carregar livros: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_books,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Sua biblioteca está vazia.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final book = snapshot.data![index];
                  return Dismissible(
                    key: Key(book.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await widget.libraryService.removeBook(book.id);
                      _loadBooks();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${book.title} removido da biblioteca')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(book.thumbnailUrl),
                        title: Text(book.title),
                        subtitle: Text(book.authors.join(', ')),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsScreen(
                                book: book,
                                libraryService: widget.libraryService,
                              ),
                            ),
                          );
                          _loadBooks();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 1,
          libraryService: widget.libraryService,
        ),
      ),
    );
  }
}
