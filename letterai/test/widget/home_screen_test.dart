// Widget tests for HomeScreen
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:letterai/screens/home/home_screen.dart';
import 'package:letterai/providers/letter_provider.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late LetterProvider letterProvider;

    setUp(() {
      letterProvider = LetterProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<LetterProvider>(
          create: (_) => letterProvider,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('HomeScreen should display app title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('LetterAI'), findsOneWidget);
    });

    testWidgets('HomeScreen should display Letter Categories section', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Letter Categories'), findsOneWidget);
    });

    testWidgets('HomeScreen should display Recent Letters section', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Recent Letters'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('HomeScreen should display quick actions', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Templates'), findsOneWidget);
    });

    testWidgets('HomeScreen should have floating action button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('New Letter'), findsOneWidget);
    });

    testWidgets('HomeScreen should have settings button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Floating action button should be tappable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Assert - In a real implementation, this would navigate to category selection
      // For now, we just verify the button can be tapped without errors
    });

    testWidgets('Quick action buttons should be tappable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act & Assert - Verify buttons exist and can be tapped
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Templates'), findsOneWidget);

      // Tap AI Assistant button
      await tester.tap(find.text('AI Assistant'));
      await tester.pump();

      // Tap Templates button
      await tester.tap(find.text('Templates'));
      await tester.pump();
    });

    testWidgets('HomeScreen should handle loading state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Trigger loading
      letterProvider.loadLetters();
      await tester.pump();

      // Assert - In a real implementation, you might show loading indicators
      // For now, we verify the screen still renders during loading
      expect(find.text('LetterAI'), findsOneWidget);
    });

    testWidgets('HomeScreen should scroll properly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Try scrolling
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();

      // Assert - Verify the screen handles scrolling
      expect(find.text('LetterAI'), findsOneWidget);
    });
  });
}
