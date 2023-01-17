import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:csv_localizations/csv_localizations.dart';

/// https://flutter.dev/docs/testing
/// https://flutter.dev/docs/cookbook/testing/unit/introduction
/// https://flutter.dev/docs/cookbook/testing/widget/introduction
/// https://stackoverflow.com/questions/49480080/flutter-load-assets-for-tests
/// https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html
/// https://stackoverflow.com/questions/52463714/how-to-test-localized-widgets-in-flutter
/// https://api.flutter.dev/flutter/widgets/LocalizationsDelegate-class.html

ByteData toByteData(String text) {
  return ByteData.view(Uint8List.fromList(utf8.encode(text)).buffer);
}

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return toByteData('key,en,en-US,nb,nb-NO\nHi,Hi,Hi US,Hei,Hei NO');
  }
}

Widget buildTestWidgetWithLocale(
  Locale locale,
  CsvLocalizationsDelegate csvLocalizationsDelegate,
) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: [
      ...GlobalMaterialLocalizations.delegates,
      csvLocalizationsDelegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('en', 'US'),
      Locale('nb'),
      Locale('nb', 'NO'),
    ],
    home: Scaffold(
      body: Builder(
        builder: (context) => Text(CsvLocalizations.instance.string('Hi')),
      ),
    ),
  );
}

// get csv localizations
CsvLocalizationsDelegate csvTestDelgate() {
  return CsvLocalizationsDelegate('assets/translations.csv', TestAssetBundle());
}

void main() {
  testWidgets('MyTestApp find [en] text', (WidgetTester tester) async {
    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('en'), csvTestDelgate()));
    await tester.pump();
    final hiFinder = find.text('Hi');
    expect(hiFinder, findsOneWidget);
  });

  testWidgets('MyTestApp find [en-US] text', (WidgetTester tester) async {
    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('en', 'US'), csvTestDelgate()));
    await tester.pump();
    final hiFinder = find.text('Hi US');
    expect(hiFinder, findsOneWidget);
  });

  testWidgets('MyTestApp find [nb] text', (WidgetTester tester) async {
    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('nb'), csvTestDelgate()));
    await tester.pump();
    final hiFinder = find.text('Hei');
    expect(hiFinder, findsOneWidget);
  });

  testWidgets('MyTestApp find [nb-NO] text', (WidgetTester tester) async {
    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('nb', 'NO'), csvTestDelgate()));
    await tester.pump();
    final hiFinder = find.text('Hei NO');
    expect(hiFinder, findsOneWidget);
  });

  testWidgets('Test Locale [nb-NO] is supported', (WidgetTester tester) async {
    final csvDelegate = csvTestDelgate();

    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('nb', 'NO'), csvDelegate));
    await tester.pumpAndSettle();

    expect(csvDelegate.isSupported(const Locale('nb', 'NO')), true);
  });

  testWidgets('Test Locale [zh] is NOT supported', (WidgetTester tester) async {
    final csvDelegate = csvTestDelgate();

    await tester.pumpWidget(
        buildTestWidgetWithLocale(const Locale('nb', 'NO'), csvDelegate));
    await tester.pumpAndSettle();

    // TODO isSupported always returns true for now
    //expect(csvDelegate.isSupported(const Locale('zh')), false);
  });

  test('Locale get codeKey from languageCode', () {
    expect(const Locale('en').toLanguageTag(), 'en');
    expect(const Locale('nb').toLanguageTag(), 'nb');
  });

  test('Locale get codeKey from languageCode and country', () {
    expect(const Locale('en', 'US').toLanguageTag(), 'en-US');
    expect(const Locale('en', 'GB').toLanguageTag(), 'en-GB');
  });
}
