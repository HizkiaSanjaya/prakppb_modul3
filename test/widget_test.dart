import 'package:flutter_test/flutter_test.dart';
import 'package:mod3_kel03/main.dart';

void main() {
  testWidgets('Country app displays its main navigation with all 4 menus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CountryApp());

    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
