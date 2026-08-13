// 教学关卡 App 基础冒烟测试

import 'package:flutter_test/flutter_test.dart';

import 'package:relation_app_teaching/main.dart';

void main() {
  testWidgets('App builds and shows teaching title', (WidgetTester tester) async {
    await tester.pumpWidget(const TeachingApp());

    // 顶部标题应出现
    expect(find.text('社交教学关卡'), findsOneWidget);
    // 教学系统概览标题应出现
    expect(find.text('社交教学系统'), findsOneWidget);
  });
}
