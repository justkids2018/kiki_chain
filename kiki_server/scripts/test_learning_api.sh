#!/bin/bash

# API测试脚本 - 学习进度系统
# 使用方法: ./test_learning_api.sh

set -e

API_BASE="http://localhost:8080"
USER_ID="test_user_001"
SCENE_ID="kiki_zhiwuyuan"

echo "🧪 开始测试学习进度API..."
echo "API地址: $API_BASE"
echo ""

# 测试1: 获取学习进度（首次，应该返回404）
echo "📡 测试1: 获取学习进度 (首次)"
curl -X GET "$API_BASE/api/v1/learning/progress/$USER_ID/$SCENE_ID" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.'

echo ""
echo "---"
echo ""

# 测试2: 提交学习进度
echo "📡 测试2: 提交学习进度"
curl -X POST "$API_BASE/api/v1/learning/progress/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "'$USER_ID'",
    "scene_id": "'$SCENE_ID'",
    "learned_regions": [
      {
        "region_id": "大象",
        "region_text": "大象",
        "region_text_english": "elephant",
        "learned_at": "2026-06-04T10:00:00Z"
      },
      {
        "region_id": "老虎",
        "region_text": "老虎",
        "region_text_english": "tiger",
        "learned_at": "2026-06-04T10:01:00Z"
      },
      {
        "region_id": "猴子",
        "region_text": "猴子",
        "region_text_english": "monkey",
        "learned_at": "2026-06-04T10:02:00Z"
      }
    ],
    "stars_earned": 1,
    "is_completed": false,
    "study_time": 120
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.'

echo ""
echo "---"
echo ""

# 测试3: 再次获取学习进度（应该返回数据）
echo "📡 测试3: 获取学习进度 (第二次)"
curl -X GET "$API_BASE/api/v1/learning/progress/$USER_ID/$SCENE_ID" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.'

echo ""
echo "---"
echo ""

# 测试4: 获取用户汇总
echo "📡 测试4: 获取用户汇总"
curl -X GET "$API_BASE/api/v1/learning/user/$USER_ID/summary" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.'

echo ""
echo "---"
echo ""

echo "✅ 测试完成！"
