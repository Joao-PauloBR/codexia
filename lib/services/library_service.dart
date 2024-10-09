import 'package:logger/logger.dart';

import '../models/book.dart';
import 'database_helper.dart';

final Logger logger = Logger();

class LibraryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Book>> get books async {
    try {
      return await _databaseHelper.getAllBooks();
    } catch (e, stackTrace) {
      logger.e('Erro ao obter a lista de livros: $e');
      logger.e('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<bool> addBook(Book book) async {
    try {
      if (await _databaseHelper.bookExists(book.id)) {
        return false;
      } else {
        await _databaseHelper.insert(book);
        return true;
      }
    } catch (e, stackTrace) {
      logger.e('Erro ao adicionar o livro: $e');
      logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> removeBook(String bookId) async {
    try {
      await _databaseHelper.delete(bookId);
      return true;
    } catch (e, stackTrace) {
      logger.e('Erro ao remover o livro: $e');
      logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> isBookInLibrary(String bookId) async {
    try {
      return await _databaseHelper.bookExists(bookId);
    } catch (e, stackTrace) {
      logger.e('Erro ao verificar se o livro está na biblioteca: $e');
      logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<List<Book>> getAllBooks() async {
    try {
      List<Book> books = await _databaseHelper.getAllBooks();
      logger.i('Obtidos ${books.length} livros da biblioteca');
      return books;
    } catch (e, stackTrace) {
      logger.e('Erro ao obter todos os livros: $e');
      logger.e('Stack trace: $stackTrace');
      return [];
    }
  }
}
