import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/theme/app_theme.dart';
import 'package:starter_app/widgets/app_button.dart';
import 'package:starter_app/widgets/app_text_field.dart';
import 'package:starter_app/widgets/empty_state.dart';
import 'package:starter_app/widgets/error_view.dart';
import 'package:starter_app/widgets/loading_view.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  group('AppButton', () {
    testWidgets('calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Go', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Go', loading: true, onPressed: () => taps++)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
    });

    testWidgets('is disabled without a callback', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Go', onPressed: null)),
      );
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('AppTextField', () {
    testWidgets('reports changes and shows the error text', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            label: 'Email',
            errorText: 'Required',
            onChanged: (v) => changed = v,
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'a@b.com');
      expect(changed, 'a@b.com');
    });

    testWidgets('has no error text by default', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextField(label: 'Email')));
      expect(find.text('Required'), findsNothing);
    });
  });

  group('LoadingView', () {
    testWidgets('shows a spinner and optional message', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingView(message: 'Loading')));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message and retries', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        _wrap(ErrorView(message: 'Boom', onRetry: () => retries++)),
      );
      expect(find.text('Boom'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('hides Retry without a callback', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Boom')));
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('shows title and message without an action', (tester) async {
      await tester.pumpWidget(
        _wrap(const EmptyState(title: 'Nothing', message: 'Add one')),
      );
      expect(find.text('Nothing'), findsOneWidget);
      expect(find.text('Add one'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('runs the action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          EmptyState(
            title: 'Nothing',
            actionLabel: 'Add',
            onAction: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Add'));
      expect(taps, 1);
    });
  });

  group('AppTheme', () {
    test('builds light and dark Material 3 themes', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
    });
  });
}
