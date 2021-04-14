import 'package:meta/meta.dart';


class Movie{

  final String title;
  final String originalTitle;
  final String description;
  final String releaseYear;
  final String posterPath;

  const Movie({
    @required this.title,
    @required this.originalTitle,
    @required this.description,
    @required this.releaseYear,
    @required this.posterPath,
  })  : assert(title != null),
        assert(description != null);
}