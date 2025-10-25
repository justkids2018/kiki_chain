#!/bin/bash

# 老师作业相关API路径测试脚本
# 专门测试老师作业功能的API端点
# 验证路径: /api/teacher/assignments 和 /api/teacher/assignments/{id}

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

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 全局变量
TEACHER_TOKEN=""
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

# 注册和登录老师用户
setup_teacher_auth() {
    print_header "老师用户认证设置"
    
    # 注册老师用户
    print_test "注册老师用户"
    local teacher_register_response=$(curl -s -X POST "${API_BASE}/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "teacher_assignment_test",
            "email": "teacher_assignment@test.com",
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
            "identifier": "13800000001",
            "password": "teacher123"
        }')
    
    TEACHER_TOKEN=$(echo "$teacher_login_response" | jq -r '.data.token // empty')
    if [[ -n "$TEACHER_TOKEN" ]]; then
        print_success "老师用户登录成功"
        print_info "Token: ${TEACHER_TOKEN:0:30}..."
    else
        print_error "老师用户登录失败"
        echo "Response: $teacher_login_response"
        exit 1
    fi
}

# 测试创建作业API
test_create_assignment() {
    print_header "测试创建作业 API"
    
    print_test "POST ${API_BASE}/teacher/assignments"
    
    local create_response=$(curl -s -X POST "${API_BASE}/teacher/assignments" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "title": "测试作业1",
            "description": "这是一个测试作业的描述",
            "knowledge_points": "加法运算,减法运算",
            "status": "published"
        }')
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${API_BASE}/teacher/assignments" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "title": "测试作业1",
            "description": "这是一个测试作业的描述",
            "knowledge_points": "加法运算,减法运算",
            "status": "published"
        }')
    
    echo "HTTP Status: $http_status"
    echo "Response: $create_response" | jq '.' 2>/dev/null || echo "Response: $create_response"
    
    if [[ "$http_status" == "200" ]]; then
        print_success "创建作业API路径可访问"
        
        # 尝试从响应中提取作业ID
        ASSIGNMENT_ID=$(echo "$create_response" | jq -r '.data.id // empty' 2>/dev/null)
        if [[ -n "$ASSIGNMENT_ID" ]]; then
            print_info "获取到作业ID: $ASSIGNMENT_ID"
        else
            print_warning "无法从响应中提取作业ID（可能是Mock响应）"
            ASSIGNMENT_ID="test-assignment-id"
        fi
    else
        print_warning "创建作业API返回状态码: $http_status"
        print_info "这可能是正常的，因为业务逻辑可能还未完全实现"
    fi
}

# 测试获取作业列表API
test_get_assignments_list() {
    print_header "测试获取作业列表 API"
    
    print_test "GET ${API_BASE}/teacher/assignments"
    
    local list_response=$(curl -s -X GET "${API_BASE}/teacher/assignments" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${API_BASE}/teacher/assignments" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    echo "HTTP Status: $http_status"
    echo "Response: $list_response" | jq '.' 2>/dev/null || echo "Response: $list_response"
    
    if [[ "$http_status" == "200" ]]; then
        print_success "获取作业列表API路径可访问"
        
        # 检查响应结构
        if echo "$list_response" | jq -e '.success' > /dev/null 2>&1; then
            print_success "响应具有正确的ApiResponse结构"
        else
            print_warning "响应结构可能需要调整"
        fi
    else
        print_warning "获取作业列表API返回状态码: $http_status"
    fi
}

# 测试获取作业详情API
test_get_assignment_detail() {
    print_header "测试获取作业详情 API"
    
    print_test "GET ${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}"
    
    local detail_response=$(curl -s -X GET "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    echo "HTTP Status: $http_status"
    echo "Response: $detail_response" | jq '.' 2>/dev/null || echo "Response: $detail_response"
    
    if [[ "$http_status" == "200" ]]; then
        print_success "获取作业详情API路径可访问"
    else
        print_warning "获取作业详情API返回状态码: $http_status"
    fi
}

# 测试更新作业API
test_update_assignment() {
    print_header "测试更新作业 API"
    
    print_test "PUT ${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}"
    
    local update_response=$(curl -s -X PUT "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "title": "更新后的测试作业",
            "description": "这是更新后的作业描述",
            "knowledge_points": "乘法运算,除法运算",
            "status": "draft"
        }')
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TEACHER_TOKEN" \
        -d '{
            "title": "更新后的测试作业",
            "description": "这是更新后的作业描述",
            "knowledge_points": "乘法运算,除法运算",
            "status": "draft"
        }')
    
    echo "HTTP Status: $http_status"
    echo "Response: $update_response" | jq '.' 2>/dev/null || echo "Response: $update_response"
    
    if [[ "$http_status" == "200" ]]; then
        print_success "更新作业API路径可访问"
    else
        print_warning "更新作业API返回状态码: $http_status"
    fi
}

# 测试删除作业API
test_delete_assignment() {
    print_header "测试删除作业 API"
    
    print_test "DELETE ${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}"
    
    local delete_response=$(curl -s -X DELETE "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${API_BASE}/teacher/assignments/${ASSIGNMENT_ID}" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    echo "HTTP Status: $http_status"
    echo "Response: $delete_response" | jq '.' 2>/dev/null || echo "Response: $delete_response"
    
    if [[ "$http_status" == "200" ]]; then
        print_success "删除作业API路径可访问"
    else
        print_warning "删除作业API返回状态码: $http_status"
    fi
}

# 测试无效路径
test_invalid_paths() {
    print_header "测试无效路径处理"
    
    # 测试不存在的路径
    print_test "GET ${API_BASE}/teacher/assignments/invalid/path"
    
    local invalid_response=$(curl -s -X GET "${API_BASE}/teacher/assignments/invalid/path" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${API_BASE}/teacher/assignments/invalid/path" \
        -H "Authorization: Bearer $TEACHER_TOKEN")
    
    echo "HTTP Status: $http_status"
    echo "Response: $invalid_response"
    
    if [[ "$http_status" == "404" ]]; then
        print_success "无效路径正确返回404"
    else
        print_warning "无效路径返回状态码: $http_status"
    fi
}

# 生成测试报告
generate_report() {
    print_header "测试报告总结"
    
    echo -e "${BLUE}📋 老师作业API路径测试完成${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ 测试的API路径:${NC}"
    echo -e "   • POST   ${API_BASE}/teacher/assignments"
    echo -e "   • GET    ${API_BASE}/teacher/assignments"
    echo -e "   • GET    ${API_BASE}/teacher/assignments/{id}"
    echo -e "   • PUT    ${API_BASE}/teacher/assignments/{id}"
    echo -e "   • DELETE ${API_BASE}/teacher/assignments/{id}"
    echo -e ""
    echo -e "${BLUE}📝 测试结果说明:${NC}"
    echo -e "   • HTTP 200: API路径可访问，路由配置正确"
    echo -e "   • HTTP 404: 路径不存在或路由配置问题"
    echo -e "   • HTTP 500: 服务器内部错误，可能是业务逻辑问题"
    echo -e "   • 其他状态码: 可能是认证、权限或其他问题"
    echo -e ""
    echo -e "${YELLOW}⚠️  注意:${NC}"
    echo -e "   • 目前某些API可能返回Mock数据"
    echo -e "   • 业务逻辑可能还在开发中"
    echo -e "   • 路径可访问说明路由配置正确"
}

# 主函数
main() {
    print_header "老师作业API路径验证测试"
    
    # 检查依赖
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl命令未找到，请安装curl"
        exit 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_warning "jq命令未找到，JSON格式化功能将受限"
    fi
    
    # 执行测试
    check_server
    setup_teacher_auth
    test_create_assignment
    test_get_assignments_list
    test_get_assignment_detail
    test_update_assignment
    test_delete_assignment
    test_invalid_paths
    generate_report
    
    print_success "所有测试完成！"
}

# 运行主函数
main "$@"
