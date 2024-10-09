import 'package:intl/intl.dart';

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnailUrl;
  final int? pageCount;
  final String? publisher;
  final DateTime? publishedDate;
  final List<String> categories;
  final String? language;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnailUrl,
    this.pageCount,
    this.publisher,
    this.publishedDate,
    this.categories = const [],
    this.language,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['volumeInfo']['title'] ?? 'Título não disponível',
      authors: List<String>.from(json['volumeInfo']['authors'] ?? []),
      description:
          json['volumeInfo']['description'] ?? 'Descrição não disponível',
      thumbnailUrl: json['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
      pageCount: json['volumeInfo']['pageCount'],
      publisher: json['volumeInfo']['publisher'],
      publishedDate: json['volumeInfo']['publishedDate'] != null
          ? DateTime.tryParse(json['volumeInfo']['publishedDate'])
          : null,
      categories: List<String>.from(json['volumeInfo']['categories'] ?? []),
      language: json['volumeInfo']['language'],
    );
  }

  String get formattedAuthors =>
      authors.isNotEmpty ? authors.join(", ") : "N/A";

  String get formattedDescription =>
      description.isNotEmpty ? description : "N/A";

  String get formattedPublishedDate {
    if (publishedDate == null) return "N/A";
    try {
      return DateFormat('dd/MM/yyyy').format(publishedDate!);
    } catch (e) {
      return "Data inválida";
    }
  }

  String get formattedLanguage {
    switch (language) {
      case "en":
        return "Inglês";
      case "pt-BR":
        return "Português (Brasil)";
      case "pt":
        return "Português";
      case "es":
        return "Espanhol";
      case "fr":
        return "Francês";
      case "de":
        return "Alemão";
      case "it":
        return "Italiano";
      case "zh":
        return "Chinês";
      case "ja":
        return "Japonês";
      case "ar":
        return "Árabe";
      case "ru":
        return "Russo";
      default:
        return language ?? "N/A";
    }
  }

  List<String> get translatedCategories {
    final translations = {
      "Fiction": "Ficção",
      "Education": "Educação",
      "Non-fiction": "Não ficção",
      "Science Fiction": "Ficção Científica",
      "Fantasy": "Fantasia",
      "Mystery": "Mistério",
      "Thriller": "Suspense",
      "Romance": "Romance",
      "Horror": "Terror",
      "Biography": "Biografia",
      "History": "História",
      "Self-help": "Autoajuda",
      "Business": "Negócios",
      "Children's": "Infantil",
      "Young Adult": "Jovem Adulto",
      "Poetry": "Poesia",
      "Comics": "Quadrinhos",
      "Cookbook": "Culinária",
      "Art": "Arte",
      "Travel": "Viagem",
      "Religion": "Religião",
      "Science": "Ciência",
      "Technology": "Tecnologia",
    };

    return categories
        .map((category) => translations[category] ?? category)
        .toList();
  }
}
