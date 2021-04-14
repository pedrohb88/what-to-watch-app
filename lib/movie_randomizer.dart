import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:provider/provider.dart';

import 'package:what_to_watch/app_language.dart';

import 'app_body.dart';
import 'settings_screen.dart';

import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:what_to_watch/app_localizations.dart';

import 'movie.dart';
import 'api.dart';

const String testDevice = '717d0eb414a97b8c';

class MovieRandomizer extends StatefulWidget {
  MovieRandomizer({
    Key key,
  }) : super(key: key);

  @override
  _MovieRandomizerState createState() => _MovieRandomizerState();
}

final _padding = EdgeInsets.all(32.0);
final _marginBottom = EdgeInsets.only(bottom: 16.0);
final _marginTop = EdgeInsets.only(top: 24.0);

class _MovieRandomizerState extends State<MovieRandomizer> {
  Movie _movie;
  var _apiKey;
  bool loadingMovie = false;

  List<Widget> widgetList = <Widget>[];

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  int _randomizeCounter = 0;
  static const int _interstitialThreshold = 10;
  static bool _adAlreadyDisplayed = false;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['movie', 'film', 'movies', 'films', 'watch'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: false,
    nonPersonalizedAds: false,
  );

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId:
            /*BannerAd.testAdUnitId*/ 'ca-app-pub-6031703646935357/3169020137',
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
         
        });
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: /*InterstitialAd
          .testAdUnitId*/ 'ca-app-pub-6031703646935357/9414987997',
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
    
      },
    );
  }

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(
        appId: /*FirebaseAdMob
            .testAppId*/'ca-app-pub-6031703646935357~3576854870');
    _bannerAd = createBannerAd()
      ..load()
      ..show();

    getApiKey().then((result) {
      _apiKey = result;
    });
  }

  @override
  void dispose() {
     _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }

  Future<String> getApiKey() async {
    final json =
        DefaultAssetBundle.of(context).loadString('config/config.json');
    final data = JsonDecoder().convert(await json);

    return data['api_key'];
  }

  Future<void> _randomizeMovie(String language) async {
    setState(() {
      loadingMovie = true;
      _randomizeCounter += 1;
    });

    final api = Api(apiKey: _apiKey);

    var randomMovie;
    while (randomMovie == null) {
      randomMovie = await api.getRandomMovie(language);
    }

    var posterPath = randomMovie['poster_path'] != null
        ? 'http://image.tmdb.org/t/p/w185${randomMovie['poster_path']}'
        : null;    
    
    if(posterPath != null){

      final http = HttpClient();
      final url = Uri.http('image.tmdb.org', '/t/p/w185${randomMovie['poster_path']}');
      final request = await http.headUrl(url);
      final response = await request.close();

      if(response.statusCode != 200) posterPath = null;
    }
   
    var releaseYear = randomMovie['release_date'].length > 0
        ? DateTime.parse(randomMovie['release_date']).year.toString()
        : null;

    var originalTitle = (randomMovie['original_title'] != '' &&
            randomMovie['original_title'] != randomMovie['title'])
        ? randomMovie['original_title']
        : null;

    setState(() {
      loadingMovie = false;

      _movie = Movie(
        title: randomMovie['title'],
        originalTitle: originalTitle,
        description: randomMovie['overview'],
        releaseYear: releaseYear,
        posterPath: posterPath,
      );
    });
  }

  Widget _buildPoster() {
    return Container(
      margin: _marginBottom,
      child: _movie.posterPath != null
          ? Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                CircularProgressIndicator(),
                FadeInImage.memoryNetwork(
                  fadeInDuration: Duration(milliseconds: 1),
                  placeholder: kTransparentImage,
                  image: _movie.posterPath,
                )
              ],
            )
          : Image.asset(
              'assets/imgs/image_placeholder.jpg',
            ),
    );
  }

  Widget _buildInfo() {
    var list = <Widget>[];

    var title = Container(
      margin: _marginBottom,
      child: Text(
        _movie.releaseYear != null
            ? '${_movie.title} (${_movie.releaseYear})'
            : _movie.title,
        style: TextStyle(
          fontSize: 20.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
    list.add(title);

    if (_movie.originalTitle != null) {
      var originalTitle = Container(
        margin: _marginBottom,
        child: Text(
            '${AppLocalizations.of(context).translate('originalTitle')}: ${_movie.originalTitle}'),
      );
      list.add(originalTitle);
    }

    var description = Container(
      child: Text(
        _movie.description.length > 0
            ? _movie.description
            : AppLocalizations.of(context).translate('overviewNotAvailable'),
        textAlign: TextAlign.justify,
      ),
    );

    list.add(description);

    return ListView(
      children: list,
    );
  }

  Widget _buildButton(bool isAlone) {
    return Container(
      margin: _marginTop,
      child: FractionallySizedBox(
        heightFactor: isAlone ? 0.2 : 0.8,
        child: ButtonTheme(
          highlightColor: Theme.of(context).primaryColorDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
          minWidth: 200.0,
          child: Consumer<AppLanguage>(
            builder: (context, appLanguage, child) {
              return RaisedButton(
                textColor: Colors.white,
                child:
                    Text(AppLocalizations.of(context).translate('buttonTitle')),
                onPressed: (){
                  var languageCode = appLanguage.appLocale.toLanguageTag();
                  _randomizeMovie(languageCode);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    List<Widget> mainColumn = <Widget>[];

    if (_movie != null) {
      mainColumn.add(Expanded(
        flex: 5,
        child: _buildPoster(),
      ));

      mainColumn.add(Expanded(
        flex: 3,
        child: _buildInfo(),
      ));
    }
    mainColumn.add(Expanded(
      flex: 2,
      child: _buildButton(mainColumn.length == 0),
    ));

    return AppBody(
      child: Column(
        mainAxisAlignment: mainColumn.length > 1
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: mainColumn,
      ),
    );
  }

  Widget _buildLoader() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Future<void> _showAboutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF3b3939),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          titleTextStyle: TextStyle(color: Colors.white),
          contentTextStyle: TextStyle(color: Colors.white),
          title: Text(
            AppLocalizations.of(context).translate('aboutTitle'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            child: SingleChildScrollView(
              child: ListBody(
                  children: <Widget>[
                Text(
                    AppLocalizations.of(context).translate('aboutDescription')),
                Text(AppLocalizations.of(context).translate('aboutDatabase')),
                Text(AppLocalizations.of(context).translate('aboutIcon')),
                Text(AppLocalizations.of(context).translate('aboutContact')),
              ].map((widget) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: widget,
                );
              }).toList()),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //print('método build principal chamado');
    widgetList = <Widget>[];
    
    //if user had clicked the button after a ad has shown
    if(_randomizeCounter % _interstitialThreshold != 0 && _adAlreadyDisplayed) {
      _adAlreadyDisplayed = false;
    }

    if (_randomizeCounter != 0 && _randomizeCounter % _interstitialThreshold == 0 && !_adAlreadyDisplayed) {
      //print('mostrar interstitial');
      _adAlreadyDisplayed = true;
      _interstitialAd?.dispose();
      _interstitialAd = createInterstitialAd()
        ..load()
        ..show();
    }

    widgetList.add(_buildBody());

    if (loadingMovie) {
      widgetList.add(_buildLoader());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('What to Watch'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: widgetList,
      ),
    );
  }
}
