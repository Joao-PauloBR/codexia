import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/library_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  final LibraryService libraryService;

  const BookDetailsScreen({
    super.key,
    required this.book,
    required this.libraryService,
  });

  @override
  BookDetailsScreenState createState() => BookDetailsScreenState();
}

class BookDetailsScreenState extends State<BookDetailsScreen> {
  late Future<bool> _isInLibraryFuture;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _isInLibraryFuture = widget.libraryService.isBookInLibrary(widget.book.id);
  }

  Future<void> _toggleLibraryStatus() async {
    bool isInLibrary = await _isInLibraryFuture;
    if (isInLibrary) {
      await widget.libraryService.removeBook(widget.book.id);
    } else {
      await widget.libraryService.addBook(widget.book);
    }
    setState(() {
      _isInLibraryFuture = Future.value(!isInLibrary);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Livro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(),
            const SizedBox(height: 16),
            _buildBookInfo(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildLibraryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.book.thumbnailUrl.isNotEmpty
            ? Image.network(
                widget.book.thumbnailUrl,
                height: 150,
              )
            : const Icon(Icons.book, size: 150),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.book.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'por ${widget.book.formattedAuthors}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                'Páginas', widget.book.pageCount?.toString() ?? 'N/A'),
            _buildInfoRow('Editora', widget.book.publisher ?? 'N/A'),
            _buildInfoRow(
                'Data de Publicação', widget.book.formattedPublishedDate),
            _buildInfoRow(
                'Categorias', widget.book.translatedCategories.join(', ')),
            _buildInfoRow('Idioma', widget.book.formattedLanguage),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(text: widget.book.formattedDescription),
                  maxLines: 5,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                if (textPainter.didExceedMaxLines) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.formattedDescription,
                        maxLines: _isDescriptionExpanded ? null : 5,
                        overflow: _isDescriptionExpanded
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Text(
                            _isDescriptionExpanded ? 'Ler menos' : 'Ler mais'),
                      ),
                    ],
                  );
                } else {
                  return Text(widget.book.formattedDescription);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryButton() {
    return FutureBuilder<bool>(
      future: _isInLibraryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else {
          bool isInLibrary = snapshot.data ?? false;
          return ElevatedButton.icon(
            onPressed: _toggleLibraryStatus,
            icon: Icon(isInLibrary ? Icons.remove : Icons.add),
            label: Text(isInLibrary
                ? 'Remover da Biblioteca'
                : 'Adicionar à Biblioteca'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          );
        }
      },
    );
  }
}
