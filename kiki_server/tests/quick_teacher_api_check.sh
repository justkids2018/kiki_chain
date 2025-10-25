#!/bin/bash

# 快速验证老师作业API路径脚本
# 用于快速检查API是否正常工作

BASE_URL="http://127.0.0.1:8081"

echo "🚀 快速验证老师作业API路径..."

# 检查服务器
if ! curl -s -f "${BASE_URL}/health" > /dev/null; then
    echo "❌ 服务器未运行，请先启动: cargo run"
    exit 1
fi

echo "✅ 服务器运行正常"

# 获取token
echo "🔐 获取认证token..."
TOKEN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"identifier": "teacher@test.com", "password": "teacher123"}' \
    | jq -r '.data.token // empty')

if [[ -z "$TOKEN" ]]; then
    echo "❌ 获取token失败"
    exit 1
fi

echo "✅ 认证成功"

# 测试所有API路径
echo "📝 测试API路径..."

apis=(
    "POST /api/teacher/assignments"
    "GET /api/teacher/assignments" 
    "GET /api/teacher/assignments/test-id"
    "PUT /api/teacher/assignments/test-id"
    "DELETE /api/teacher/assignments/test-id"
)

for api in "${apis[@]}"; do
    method=$(echo $api | cut -d' ' -f1)
    path=$(echo $api | cut -d' ' -f2)
    
    status=$(curl -s -o /dev/null -w "%{http_code}" -X $method "${BASE_URL}${path}" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"title":"test"}')
    
    if [[ "$status" == "200" ]]; then
        echo "✅ $api - HTTP $status"
    else
        echo "⚠️  $api - HTTP $status"
    fi
done

echo "🎉 验证完成！"
