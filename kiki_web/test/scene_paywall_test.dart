import 'package:flutter_test/flutter_test.dart';
import 'package:kikichain/domain/entities/scene.dart';
import 'package:kikichain/domain/entities/scene_category.dart';
import 'package:kikichain/domain/entities/user.dart';
import 'package:kikichain/domain/repositories/i_auth_repository.dart';
import 'package:kikichain/domain/repositories/i_scene_repository.dart';
import 'package:kikichain/presentation/controllers/home_controller.dart';
import 'package:kikichain/presentation/controllers/scene_list_controller.dart';

void main() {
  test(
      'home category paywall keeps first category free and locks later categories for non VIP',
      () {
    final controller = HomeController(
      authRepository: _FakeAuthRepository(),
      sceneRepository: _FakeSceneRepository(const []),
    );

    expect(controller.categoryRequiresVip(0), isFalse);
    expect(controller.categoryIsLocked(0), isFalse);
    expect(controller.categoryRequiresVip(1), isTrue);
    expect(controller.categoryIsLocked(1), isTrue);

    controller.currentUser.value = _user(isVip: true);

    expect(controller.categoryRequiresVip(1), isTrue);
    expect(controller.categoryIsLocked(1), isFalse);
  });

  test('scene list uses progression locks instead of per-scene VIP locks',
      () async {
    final category = _category();
    final controller = SceneListController(
      category: category,
      sceneRepository: _FakeSceneRepository([
        _scene('scene_free', category.id, 1),
        _scene('scene_second', category.id, 2),
      ]),
    );

    await controller.loadScenes();

    expect(controller.scenes, hasLength(2));
    expect(controller.scenes[0].requiresVip, isFalse);
    expect(controller.scenes[0].isLocked, isFalse);
    expect(controller.scenes[1].requiresVip, isFalse);
    expect(controller.scenes[1].isLocked, isTrue);
  });
}

SceneCategory _category() {
  return SceneCategory(
    id: 'cat_test',
    name: '测试分类',
    icon: '',
    coverImage: '',
    description: '',
    sceneCount: 2,
    totalItemCount: 0,
    order: 1,
    isNew: false,
    createdAt: DateTime(2026, 1, 1),
  );
}

Scene _scene(String id, String categoryId, int order) {
  return Scene(
    id: id,
    name: id,
    nameEn: id,
    categoryId: categoryId,
    coverImage: '',
    interactiveImage: '',
    description: '',
    context: '',
    itemCount: 1,
    order: order,
    isNew: false,
    createdAt: DateTime(2026, 1, 1),
  );
}

User _user({required bool isVip}) {
  return User(
    id: 'user_test',
    phone: '13800000000',
    nickname: 'Kiki',
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 1),
    isVip: isVip,
    vipExpireAt: DateTime(2027, 1, 1),
  );
}

class _FakeSceneRepository implements ISceneRepository {
  _FakeSceneRepository(this._scenes);

  final List<Scene> _scenes;

  @override
  Future<List<SceneCategory>> getCategories() async => const [];

  @override
  Future<Map<String, dynamic>> getSceneDetail(String sceneId) async => {};

  @override
  Future<List<Scene>> getScenesByCategory(String categoryId) async => _scenes;

  @override
  Future<List<Scene>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async =>
      const [];
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<void> clearAuthData() async {}

  @override
  Future<bool> checkServerHealth() async => true;

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<User?> login(String phone, String password) async => null;

  @override
  Future<bool> logout() async => true;

  @override
  Future<String?> refreshAccessToken() async => null;

  @override
  Future<User?> refreshCurrentUser() async => null;

  @override
  Future<User?> register(
    String phone,
    String password, {
    String? nickname,
  }) async =>
      null;

  @override
  Future<User?> updateUserInfo(Map<String, dynamic> userData) async => null;

  @override
  Future<bool> verifyToken() async => false;
}
