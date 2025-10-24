import 'package:flutter_test/flutter_test.dart';
import 'package:kikichain/presentation/controllers/auth_controller.dart';

void main() {
  group('邀请码验证测试', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    test('验证当前月份邀请码 - 正确格式', () {
      // 获取当前月份
      final currentMonth = DateTime.now().month;
      final correctInviteCode = currentMonth.toString().padLeft(2, '0') + '01';
      
      print('当前月份: $currentMonth');
      print('正确的邀请码: $correctInviteCode');
      
      expect(authController.validateInviteCode(correctInviteCode), true);
    });

    test('验证错误月份邀请码', () {
      // 使用非当前月份的邀请码
      final currentMonth = DateTime.now().month;
      final wrongMonth = currentMonth == 12 ? 1 : currentMonth + 1;
      final wrongInviteCode = wrongMonth.toString().padLeft(2, '0') + '01';
      
      print('错误月份邀请码: $wrongInviteCode');
      
      expect(authController.validateInviteCode(wrongInviteCode), false);
    });

    test('验证非01日邀请码', () {
      // 使用当前月份但非01日的邀请码
      final currentMonth = DateTime.now().month;
      final wrongDayInviteCode = currentMonth.toString().padLeft(2, '0') + '02';
      
      print('错误日期邀请码: $wrongDayInviteCode');
      
      expect(authController.validateInviteCode(wrongDayInviteCode), false);
    });

    test('验证格式错误的邀请码', () {
      // 测试各种格式错误
      expect(authController.validateInviteCode('123'), false);  // 3位数字
      expect(authController.validateInviteCode('12345'), false);  // 5位数字
      expect(authController.validateInviteCode('abcd'), false);  // 字母
      expect(authController.validateInviteCode('12a1'), false);  // 混合字符
      expect(authController.validateInviteCode(''), false);  // 空字符串
      expect(authController.validateInviteCode('1301'), false);  // 无效月份
      expect(authController.validateInviteCode('0001'), false);  // 无效月份
    });

    test('验证边界值', () {
      // 测试1月和12月的邀请码
      final currentMonth = DateTime.now().month;
      
      // 如果当前是1月，测试0101
      if (currentMonth == 1) {
        expect(authController.validateInviteCode('0101'), true);
        expect(authController.validateInviteCode('1201'), false); // 12月应该无效
      }
      
      // 如果当前是12月，测试1201
      if (currentMonth == 12) {
        expect(authController.validateInviteCode('1201'), true);
        expect(authController.validateInviteCode('0101'), false); // 1月应该无效
      }
    });

    tearDown(() {
      authController.dispose();
    });
  });
}