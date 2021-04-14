import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:what_to_watch/app_localizations.dart';
import 'package:what_to_watch/app_language.dart';
import 'package:what_to_watch/app_settings.dart';
import 'package:what_to_watch/movie_randomizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.updateLocale();
  
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  final AppLanguage appLanguage;

  MyApp({@required this.appLanguage}) : assert(appLanguage != null);

  @override
  _MyAppState createState() => _MyAppState();
}

const MaterialColor myColour = const MaterialColor(
  0xFFBF1F00, 
  const <int, Color>{
    50: const Color(0xFFfbe8e6),
    100: const Color(0xFFffc9b9),
    200: const Color(0xFFffa58c),
    300: const Color(0xFFff815f),
    400: const Color(0xFFff633c),
    500: const Color(0xFFfe4519),
    600: const Color(0xFFf33f15),
    700: const Color(0xFFe5380f),
    800: const Color(0xFFd7300a),
    900: const Color(0xFFbf2000),
});

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => widget.appLanguage),
        ChangeNotifierProvider(create: (context) => AppSettings()),
      ],
      child: Consumer<AppLanguage>(
        builder: (context, appLanguage, child) {

          return MaterialApp(
            title: 'What to Watch',
            theme: ThemeData(
              primarySwatch: myColour,
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                  ),
            ),
            home: MovieRandomizer(),
            locale: appLanguage.appLocale,
            supportedLocales: appLanguage.supportedLocales.values,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales){

              if(appLanguage.appLocale == null) {
                appLanguage.changeLanguage(Locale(
                  deviceLocale.languageCode, 
                  deviceLocale.countryCode
                ));
              }
            },
          );
        },
      ),
    );
  }
}
