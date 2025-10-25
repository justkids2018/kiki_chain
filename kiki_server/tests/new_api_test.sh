#!/bin/bash

# 新功能API测试脚本
# 测试老师作业管理和学生功能的API端点
# 基于你的需求文档创建的测试用例

set -e

# 配置
BASE_URL="http://127.0.0.1:8081"
API_BASE="${BASE_URL}/api"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 输出函数
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_test() {
    echo -e "${YELLOW}📝 Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 全局变量
TEACHER_TOKEN=""
STUDENT_TOKEN=""
ASSIGNMENT_ID=""

# 检查服务器是否运行
check_server() {
    print_test "检查服务器状态"
    
    if curl -s -f "${BASE_URL}/health" > /dev/null 2>&1; then
        print_success "服务器运行正常"
        return 0
    else
        print_error "服务器未运行，请先启动服务器: cargo run"
        exit 1
    fi
}

# 注册和登录用户
setup_users() {
    print_header "用户注册和登录测试"
    
    # 注册老师用户
    print_test "注册老师用户"
    local teacher_register_response=$(curl -s -X POST "${API_BASE}/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "teacher_test",
            "email": "teacher@test.com",
            "password": "teacher123",
            "phone": "13800000001"
        }' || echo '{"success": false}')
    
    if echo "$teacher_register_response" | jq -e '.success' > /dev/null 2>&1; then
        print_success "老师用户注册成功"
    else
        print_info "老师用户可能已存在，继续登录测试"
    fi
    
    # 登录老师用户
    print_test "登录老师用户"
    local teacher_login_response=$(curl -s -X POST "${API_BASE}/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "identifier": "teacher@test.com",
            "password": "teacher123"
        }')
    
    TEACHER_TOKEN=$(echo "$teacher_login_response" | jq -r '.data.token // empty')
    if [[ -n "$TEACHER_TOKEN" ]]; then
        print_success "老师用户登录成功"
        print_info "Token: ${TEACHER_TOKEN:0:20}..."
    else
        print_error "老师用户登录失败"
        echo "Response: $teacher_login_response"
        exit 1
    fi
    
    # 注册学生用户
    print_test "注册学生用户"
    local student_register_response=$(curl -s -X POST "${API_BASE}/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "student_test",
            "email": "student@test.com",
            "password": "student123",
            "phone": "13800000002"
        }' || echo '{"success": false}')
    
    if echo "$student_register_response" | jq -e '.success' > /dev/null 2>&1; then
        print_success "学生用户注册成功"
    else
        print_info "学生用户可能已存在，继续登录测试"
    fi
    
    # 登录学生用户
    print_test "登录学生用户"
    local student_login_response=$(curl -s -X POST "${API_BASE}/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "identifier": "student@test.com",
            "password": "student123"
        }')
    
    STUDENT_TOKEN=$(echo "$student_login_response" | jq -r '.data.token // empty')
    if [[ -n "$STUDENT_TOKEN" ]]; then
        print_success "学生用户登录成功"
        print_info "Token: ${STUDENT_TOKEN:0:20}..."
    else
        print_error "学生用户登录失败"
        echo "Response: $student_login_response"
        exit 1
    fi
}

# 测试老师作业功能
test_teacher_assignment_apis() {
    print_header "老师作业功能测试"
    
    # 1. 创建作业
    print_test "创建作业"
    local create_response=$(curl -s -X POST "${API_BASE}/teacher/assignments" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "teacher_id": "teacher_test_uid",
            "title": "数学练习题",
            "description": "这是一个数学练习作业",
            "knowledge_points": "加法运算,减法运算"
        }')
    
    ASSIGNMENT_ID=$(echo "$create_response" | jq -r '.data.id // empty')
    if [[ -n "$ASSIGNMENT_ID" ]]; then
        print_success "作业创建成功 - ID: $ASSIGNMENT_ID"
    else
        print_error "作业创建失败"
        echo "Response: $create_response"
        return
    fi
    
    # 2. 获取作业列表
    print_test "获取作业列表"
    local list_response=$(curl -s -X GET "${API_BASE}/teacher/assignments?teacher_id=teacher_test_uid" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local assignment_count=$(echo "$list_response" | jq -r '.data.total // 0')
    if [[ "$assignment_count" -gt 0 ]]; then
        print_success "作业列表获取成功 - 共 $assignment_count 个作业"
    else
        print_error "作业列表获取失败"
        echo "Response: $list_response"
    fi
    
    # 3. 获取作业详情
    print_test "获取作业详情"
    local detail_response=$(curl -s -X GET "${API_BASE}/teacher/assignments/$ASSIGNMENT_ID?teacher_id=teacher_test_uid" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local assignment_title=$(echo "$detail_response" | jq -r '.data.title // empty')
    if [[ "$assignment_title" == "数学练习题" ]]; then
        print_success "作业详情获取成功"
    else
        print_error "作业详情获取失败"
        echo "Response: $detail_response"
    fi
    
    # 4. 更新作业
    print_test "更新作业"
    local update_response=$(curl -s -X PUT "${API_BASE}/teacher/assignments/$ASSIGNMENT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "teacher_id": "teacher_test_uid",
            "title": "数学练习题(已更新)",
            "status": "published"
        }')
    
    local updated_title=$(echo "$update_response" | jq -r '.data.title // empty')
    if [[ "$updated_title" == "数学练习题(已更新)" ]]; then
        print_success "作业更新成功"
    else
        print_error "作业更新失败"
        echo "Response: $update_response"
    fi
}

# 测试学生功能
test_student_apis() {
    print_header "学生功能测试"
    
    # 1. 获取老师列表
    print_test "获取老师列表"
    local teachers_response=$(curl -s -X GET "${API_BASE}/student/teachers?student_id=student_test_uid" \
        -H "Authorization: Bearer $STUDENT_TOKEN")
    
    local teachers_count=$(echo "$teachers_response" | jq -r '.data.total // 0')
    if [[ "$teachers_count" -gt 0 ]]; then
        print_success "老师列表获取成功 - 共 $teachers_count 位老师"
    else
        print_info "老师列表为空或获取失败"
        echo "Response: $teachers_response"
    fi
    
    # 2. 设置默认老师
    print_test "设置默认老师"
    local set_default_response=$(curl -s -X POST "${API_BASE}/student/default-teacher" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $STUDENT_TOKEN" \
        -d '{
            "student_id": "student_test_uid",
            "teacher_id": "teacher_test_uid"
        }')
    
    if echo "$set_default_response" | jq -e '.success' > /dev/null 2>&1; then
        print_success "默认老师设置成功"
    else
        print_error "默认老师设置失败"
        echo "Response: $set_default_response"
    fi
    
    # 3. 获取默认老师
    print_test "获取默认老师"
    local get_default_response=$(curl -s -X GET "${API_BASE}/student/default-teacher?student_id=student_test_uid" \
        -H "Authorization: Bearer $STUDENT_TOKEN")
    
    local default_teacher=$(echo "$get_default_response" | jq -r '.data.teacher_id // empty')
    if [[ "$default_teacher" == "teacher_test_uid" ]]; then
        print_success "默认老师获取成功"
    else
        print_info "默认老师获取结果异常"
        echo "Response: $get_default_response"
    fi
    
    # 4. 获取老师的作业列表
    print_test "获取老师的作业列表"
    local teacher_assignments_response=$(curl -s -X GET "${API_BASE}/student/teacher/teacher_test_uid/assignments?student_id=student_test_uid" \
        -H "Authorization: Bearer $STUDENT_TOKEN")
    
    local assignments_count=$(echo "$teacher_assignments_response" | jq -r '.data.total // 0')
    if [[ "$assignments_count" -gt 0 ]]; then
        print_success "老师作业列表获取成功 - 共 $assignments_count 个作业"
    else
        print_info "老师作业列表为空"
        echo "Response: $teacher_assignments_response"
    fi
    
    # 5. 更新会话ID
    if [[ -n "$ASSIGNMENT_ID" ]]; then
        print_test "更新会话ID"
        local conversation_response=$(curl -s -X PUT "${API_BASE}/student/conversation" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $STUDENT_TOKEN" \
            -d "{
                \"assignment_id\": \"$ASSIGNMENT_ID\",
                \"student_id\": \"student_test_uid\",
                \"conversation_id\": \"conv_$(date +%s)\"
            }")
        
        if echo "$conversation_response" | jq -e '.success' > /dev/null 2>&1; then
            print_success "会话ID更新成功"
        else
            print_error "会话ID更新失败"
            echo "Response: $conversation_response"
        fi
    fi
}

# 清理测试数据（可选）
cleanup_test_data() {
    print_header "清理测试数据"
    
    if [[ -n "$ASSIGNMENT_ID" ]]; then
        print_test "删除测试作业"
        local delete_response=$(curl -s -X DELETE "${API_BASE}/teacher/assignments/$ASSIGNMENT_ID" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $TEACHER_TOKEN" \
            -d '{
                "teacher_id": "teacher_test_uid"
            }')
        
        if echo "$delete_response" | jq -e '.success' > /dev/null 2>&1; then
            print_success "测试作业删除成功"
        else
            print_error "测试作业删除失败"
            echo "Response: $delete_response"
        fi
    fi
}

# 主测试函数
main() {
    print_header "🧪 奇奇漫游记 API 功能测试"
    
    # 检查依赖
    if ! command -v jq &> /dev/null; then
        print_error "需要安装 jq 来解析 JSON 响应"
        print_info "安装命令: brew install jq (macOS) 或 apt-get install jq (Ubuntu)"
        exit 1
    fi
    
    check_server
    setup_users
    test_teacher_assignment_apis
    test_student_apis
    
    echo
    read -p "是否清理测试数据？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_test_data
    fi
    
    print_success "API测试完成！"
    print_info "查看服务器日志了解详细执行情况"
}

main "$@"
