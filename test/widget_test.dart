import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_app_admin/main.dart';
import 'package:music_app_admin/pages/login_page/login_page.dart';

void main() {
  testWidgets('shows the public landing page', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Nyro brings'), findsOneWidget);
    expect(find.text('Download for Android'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .where((image) =>
              (image.image as AssetImage).assetName == 'assets/my_bg_2.png')
          .single
          .filterQuality,
      FilterQuality.high,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sizes the login background independently of device pixel ratio',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    final backgrounds = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) =>
            (image.image as AssetImage).assetName == 'assets/my_bg_2.png')
        .toList();

    expect(backgrounds, hasLength(2));
    expect(backgrounds.every((image) => image.height == 600), isTrue);
    expect(backgrounds.first.width, closeTo(600 * 16 / 3, 0.001));
    expect(
      backgrounds.every(
          (image) => image.filterQuality == FilterQuality.high),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
