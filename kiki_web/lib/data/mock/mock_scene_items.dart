import '../../domain/entities/scene_item.dart';

/// Mock Scene Items Data
///
/// 提供场景物品的模拟数据
class MockSceneItems {
  /// 早餐时间场景物品 (12个)
  static final List<SceneItem> breakfastItems = [
    SceneItem(
      id: 'item_breakfast_milk',
      sceneId: 'scene_breakfast',
      nameCn: '牛奶',
      nameEn: 'Milk',
      pinyin: 'niú nǎi',
      pronunciation: 'niu2 nai3',
      imageUrl: 'assets/images/items/breakfast/milk.png',
      audioUrl: 'assets/audio/items/breakfast/milk.mp3',
      order: 1,
      hotspot: {
        'type': 'rect',
        'x': 100.0,
        'y': 150.0,
        'width': 80.0,
        'height': 120.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_bread',
      sceneId: 'scene_breakfast',
      nameCn: '面包',
      nameEn: 'Bread',
      pinyin: 'miàn bāo',
      pronunciation: 'mian4 bao1',
      imageUrl: 'assets/images/items/breakfast/bread.png',
      audioUrl: 'assets/audio/items/breakfast/bread.mp3',
      order: 2,
      hotspot: {
        'type': 'rect',
        'x': 200.0,
        'y': 180.0,
        'width': 100.0,
        'height': 80.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_egg',
      sceneId: 'scene_breakfast',
      nameCn: '鸡蛋',
      nameEn: 'Egg',
      pinyin: 'jī dàn',
      pronunciation: 'ji1 dan4',
      imageUrl: 'assets/images/items/breakfast/egg.png',
      audioUrl: 'assets/audio/items/breakfast/egg.mp3',
      order: 3,
      hotspot: {
        'type': 'circle',
        'x': 350.0,
        'y': 200.0,
        'radius': 40.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_juice',
      sceneId: 'scene_breakfast',
      nameCn: '果汁',
      nameEn: 'Juice',
      pinyin: 'guǒ zhī',
      pronunciation: 'guo3 zhi1',
      imageUrl: 'assets/images/items/breakfast/juice.png',
      audioUrl: 'assets/audio/items/breakfast/juice.mp3',
      order: 4,
      hotspot: {
        'type': 'rect',
        'x': 450.0,
        'y': 160.0,
        'width': 70.0,
        'height': 110.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_butter',
      sceneId: 'scene_breakfast',
      nameCn: '黄油',
      nameEn: 'Butter',
      pinyin: 'huáng yóu',
      pronunciation: 'huang2 you2',
      imageUrl: 'assets/images/items/breakfast/butter.png',
      audioUrl: 'assets/audio/items/breakfast/butter.mp3',
      order: 5,
      hotspot: {
        'type': 'rect',
        'x': 300.0,
        'y': 250.0,
        'width': 60.0,
        'height': 50.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_jam',
      sceneId: 'scene_breakfast',
      nameCn: '果酱',
      nameEn: 'Jam',
      pinyin: 'guǒ jiàng',
      pronunciation: 'guo3 jiang4',
      imageUrl: 'assets/images/items/breakfast/jam.png',
      audioUrl: 'assets/audio/items/breakfast/jam.mp3',
      order: 6,
      hotspot: {
        'type': 'rect',
        'x': 380.0,
        'y': 250.0,
        'width': 60.0,
        'height': 50.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_cereal',
      sceneId: 'scene_breakfast',
      nameCn: '麦片',
      nameEn: 'Cereal',
      pinyin: 'mài piàn',
      pronunciation: 'mai4 pian4',
      imageUrl: 'assets/images/items/breakfast/cereal.png',
      audioUrl: 'assets/audio/items/breakfast/cereal.mp3',
      order: 7,
      hotspot: {
        'type': 'rect',
        'x': 550.0,
        'y': 180.0,
        'width': 90.0,
        'height': 100.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_yogurt',
      sceneId: 'scene_breakfast',
      nameCn: '酸奶',
      nameEn: 'Yogurt',
      pinyin: 'suān nǎi',
      pronunciation: 'suan1 nai3',
      imageUrl: 'assets/images/items/breakfast/yogurt.png',
      audioUrl: 'assets/audio/items/breakfast/yogurt.mp3',
      order: 8,
      hotspot: {
        'type': 'rect',
        'x': 150.0,
        'y': 280.0,
        'width': 70.0,
        'height': 90.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_spoon',
      sceneId: 'scene_breakfast',
      nameCn: '勺子',
      nameEn: 'Spoon',
      pinyin: 'sháo zi',
      pronunciation: 'shao2 zi',
      imageUrl: 'assets/images/items/breakfast/spoon.png',
      audioUrl: 'assets/audio/items/breakfast/spoon.mp3',
      order: 9,
      hotspot: {
        'type': 'rect',
        'x': 250.0,
        'y': 320.0,
        'width': 80.0,
        'height': 30.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_fork',
      sceneId: 'scene_breakfast',
      nameCn: '叉子',
      nameEn: 'Fork',
      pinyin: 'chā zi',
      pronunciation: 'cha1 zi',
      imageUrl: 'assets/images/items/breakfast/fork.png',
      audioUrl: 'assets/audio/items/breakfast/fork.mp3',
      order: 10,
      hotspot: {
        'type': 'rect',
        'x': 340.0,
        'y': 320.0,
        'width': 80.0,
        'height': 30.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_plate',
      sceneId: 'scene_breakfast',
      nameCn: '盘子',
      nameEn: 'Plate',
      pinyin: 'pán zi',
      pronunciation: 'pan2 zi',
      imageUrl: 'assets/images/items/breakfast/plate.png',
      audioUrl: 'assets/audio/items/breakfast/plate.mp3',
      order: 11,
      hotspot: {
        'type': 'circle',
        'x': 280.0,
        'y': 220.0,
        'radius': 60.0,
      },
    ),
    SceneItem(
      id: 'item_breakfast_cup',
      sceneId: 'scene_breakfast',
      nameCn: '杯子',
      nameEn: 'Cup',
      pinyin: 'bēi zi',
      pronunciation: 'bei1 zi',
      imageUrl: 'assets/images/items/breakfast/cup.png',
      audioUrl: 'assets/audio/items/breakfast/cup.mp3',
      order: 12,
      hotspot: {
        'type': 'rect',
        'x': 120.0,
        'y': 200.0,
        'width': 60.0,
        'height': 80.0,
      },
    ),
  ];

  /// 获取所有场景物品
  static final Map<String, List<SceneItem>> allItems = {
    'scene_breakfast': breakfastItems,
    // TODO: 添加其他场景的物品数据
  };

  /// 根据场景ID获取物品列表
  static List<SceneItem> getItemsBySceneId(String sceneId) {
    return allItems[sceneId] ?? [];
  }

  /// 获取场景详情响应（包含物品列表）
  static Map<String, dynamic> getSceneDetailResponse(String sceneId) {
    final items = getItemsBySceneId(sceneId);

    return {
      "code": 200,
      "message": "成功",
      "data": {
        "scene_id": sceneId,
        "items": items.map((item) => item.toJson()).toList(),
      }
    };
  }
}

