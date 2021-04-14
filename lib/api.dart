import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Api {
  final httpClient = HttpClient();
  final url = 'api.themoviedb.org';
  String apiKey;

  static const String includeAdult = 'false';
  static final DateTime minDate = DateTime.parse('1874-01-01');
  static final DateTime maxDate = DateTime.now();

  static var queryMap = {
    'api_key': null,
    'language': null,
    'include_adult': includeAdult,
    'primary_release_date.gte': null,
    };

  Api({
    @required this.apiKey,
  }) : assert(apiKey != null);

  Future<int> _getMaxPages() async{

    final uri = Uri.https(url, '/3/discover/movie', queryMap);

    final httpRequest = await httpClient.getUrl(uri);
    final httpResponse = await httpRequest.close();

    if (httpResponse.statusCode != HttpStatus.ok) {
      return null;
    }

    final responseBody = await httpResponse.transform(utf8.decoder).join();
    final jsonResponse = json.decode(responseBody);

    return jsonResponse['total_pages'];
  }

  int randomInt(int min, int max) {

    var sub = max - min == 0 ? 1:max-min;
 
     var rand = math.Random();
     return min + rand.nextInt(sub);
  }

  String _randomStringDate() {

    print('maxDate Year: ${maxDate.year}');
    print('maxDate Month: ${maxDate.month}');

    final randomDate = DateTime(
      randomInt(minDate.year, maxDate.year),
      randomInt(minDate.month, maxDate.month),
      1,
    );
  
    var year = addZero(randomDate.year);
    var month = addZero(randomDate.month);
    var day = addZero(randomDate.day);

    return '$year-$month-$day';
  }

  String addZero(int number) {
    var string = number.toString();

    return string.length == 1 ? '0$string' : string;
  }

  bool invalidMovie(var movie) {
    return (movie == null || movie['overview'] == null || movie['overview'] == '');
  }

  Future<dynamic> getRandomMovie(String language) async {

    Map<String, dynamic> randomMovie;

    queryMap['api_key'] = apiKey;
    queryMap['language'] = language;
    queryMap['primary_release_date.gte'] = _randomStringDate();

    int maxPages = await _getMaxPages();

    int pagesReviewd = 0;

    while(randomMovie == null){
      pagesReviewd++;
      print('Páginas analisadas: $pagesReviewd');

      int randomPage = randomInt(1, maxPages);
      queryMap['page'] = randomPage.toString();

      final uri = Uri.https(url, '/3/discover/movie', queryMap);

      final httpRequest = await httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();

      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }

      final responseBody = await httpResponse.transform(utf8.decoder).join();
      final jsonResponse = json.decode(responseBody);

      List<dynamic> movies =  jsonResponse['results'];

      int randIndex = randomInt(0, movies.length-1);
      randomMovie = movies[randIndex];

      int moviesReviewd = 1;
      while(invalidMovie(randomMovie) && movies.length != 0) {
        moviesReviewd++;
        print('Filmes analisados: $moviesReviewd');
        movies.removeAt(randIndex);

        randIndex = randomInt(0, movies.length-1);
        randomMovie = movies[randIndex];
      }

      if(invalidMovie(randomMovie)) randomMovie = null;
    }

    return randomMovie;
  }
}
