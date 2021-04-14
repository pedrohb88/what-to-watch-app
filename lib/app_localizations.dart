import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:what_to_watch/app_language.dart';

class AppLocalizations{

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {

    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings;

  Future<bool> load() async {

    var localeCode = getLocaleCode();
    String jsonString = await rootBundle.loadString('i18n/$localeCode.json');

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key];
  }

  String getLocaleCode() {

    var countryCode = locale.countryCode != null ? locale.countryCode : '';
    var localeCode = locale.countryCode != null 
                     ? '${locale.languageCode}_$countryCode'
                     : locale.languageCode;
    return localeCode;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLanguage().isSupported(locale);

  @override 
  Future<AppLocalizations> load(Locale locale) async {

    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();

    return localizations;
  }

  @override 
  bool shouldReload(_AppLocalizationsDelegate old) => false;

}

