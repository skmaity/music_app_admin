import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_app_admin/main.dart';

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
    expect(tester.takeException(), isNull);
  });
}
