import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_watch/app_localizations.dart';

class AppLanguage extends ChangeNotifier {

  Locale _appLocale;

  final _defaultLocale = Locale('en');
  final _supportedLocales = <String, Locale>{
    'English (United States)': Locale('en'),
    'Español (España)': Locale('es', 'ES'),
    'Français (France)': Locale('fr', 'FR'),
    'Português (Brasil)': Locale('pt', 'BR'),
  };

  Locale get appLocale => _appLocale;
  
  Map<String, Locale> get supportedLocales => _supportedLocales;

  Locale getLocaleFromCode(String languageFullCode) {

    var locale;

    if(languageFullCode.contains('_')) {
      var languageCode = languageFullCode.split('_')[0];
      var countryCode = languageFullCode.split('_')[1];

      locale = Locale(languageCode, countryCode);
    } else {
      locale = Locale(languageFullCode);
    }

    return locale;
  }

  /*Future<void> saveSupportedLocales(supported) async {
    _supportedLocales = supported;

    var prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('supported_locales')) {
      await prefs.setString('supported_locales', supported.toString());
    }
    return;
  }*/

  Future<void> updateLocale() async {

    var prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('language_full_code')) {
      
      _appLocale = null;
      return;
    } else {

      _appLocale = getLocaleFromCode(prefs.getString('language_full_code'));
      return;
    }
  }

  Future<void> changeLanguage(Locale locale) async {

    var prefs = await SharedPreferences.getInstance();

    if(_appLocale == locale) return;

    if(isSupported(locale)) {
      _appLocale = locale;
    } else {
      _appLocale = _defaultLocale;
    }

    var languageFullCode = AppLocalizations(_appLocale).getLocaleCode();
    await prefs.setString('language_full_code', languageFullCode);

    notifyListeners();
    return;
  }

  bool isSupported(Locale locale) => _supportedLocales.containsValue(locale);
}