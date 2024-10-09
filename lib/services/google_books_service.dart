import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> searchBooks(String query,
      {int page = 1, int maxResults = 20}) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API_KEY não encontrada ou vazia no arquivo .env');
    }

    if (query.isEmpty) {
      throw Exception('A consulta não pode ser vazia');
    }

    final startIndex = (page - 1) * maxResults;

    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl?q=$query&startIndex=$startIndex&maxResults=$maxResults&key=$apiKey'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Book.fromJson(item)).toList();
      } else if (response.statusCode == 403) {
        throw Exception(
            'Limite de requisições excedido ou chave de API inválida');
      } else if (response.statusCode == 404) {
        throw Exception('Nenhum resultado encontrado');
      } else {
        throw Exception('Erro desconhecido: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar os dados recebidos');
      } else {
        throw Exception('Erro ao buscar livros: $e');
      }
    }
  }
}
