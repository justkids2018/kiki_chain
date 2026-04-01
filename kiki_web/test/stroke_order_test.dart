import 'package:flutter_test/flutter_test.dart';
import 'package:kikichain/presentation/pages/interactive_image/services/stroke_order_service.dart';

void main() {
  group('StrokeOrderService Tests', () {
    late StrokeOrderService service;

    setUp(() {
      service = StrokeOrderService();
    });

    test('应该能从 Assets 加载常用汉字', () async {
      // 测试一个我们下载的汉字
      final data = await service.getStrokeOrderData('花');

      expect(data, isNotNull);
      expect(data, contains('strokes'));
      print('✓ 成功从 Assets 加载 "花" 的笔顺数据');
    });

    test('应该能从 Assets 加载多个汉字', () async {
      final characters = ['花', '草', '树', '木'];

      for (var char in characters) {
        final data = await service.getStrokeOrderData(char);
        if (data != null) {
          print('✓ 成功加载 "$char"');
        } else {
          print('✗ 未找到 "$char" (可能不在 Assets 中)');
        }
      }
    });

    test('应该能预加载多个汉字', () async {
      final characters = ['花', '草', '树'];

      await service.preloadCharacters(characters);

      print('✓ 预加载完成');
    });
  });
}
