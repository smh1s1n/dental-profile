import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dental_profile/main.dart';
import 'package:dental_profile/core/constants/app_strings.dart';

void main() {
  testWidgets('App renders doctor portfolio successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DentalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.doctorName), findsWidgets);
  });
}
