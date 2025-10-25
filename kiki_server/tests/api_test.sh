#!/bin/bash

# API测试脚本
# 测试所有API端点的功能，包括认证、CRUD操作等
# 同时验证日志记录、错误处理和CORS功能

set -e  # 遇到错误立即退出

# 配置
BASE_URL="http://127.0.0.1:8081"
API_BASE="${BASE_URL}/api/v1"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查服务器是否运行
check_server() {
    print_test "Checking if server is running"
    
    if curl -s -f "${BASE_URL}/static" > /dev/null 2>&1; then
        print_success "Server is running"
        return 0
    else
        print_error "Server is not running. Please start the server first:"
        print_info "Run: cargo run"
        exit 1
    fi
}

# 测试静态文件服务
test_static_files() {
    print_test "Static file serving"
    
    response=$(curl -s -w "%{http_code}" "${BASE_URL}/static/")
    http_code="${response: -3}"
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 404 ]; then
        print_success "Static files endpoint accessible (HTTP $http_code)"
    else
        print_error "Static files endpoint failed (HTTP $http_code)"
    fi
}

# 测试CORS
test_cors() {
    print_test "CORS functionality"
    
    # 预检请求
    response=$(curl -s -w "%{http_code}" -X OPTIONS \
        -H "Origin: http://localhost:3000" \
        -H "Access-Control-Request-Method: POST" \
        -H "Access-Control-Request-Headers: Content-Type,Authorization" \
        "${API_BASE}/auth/login")
    
    http_code="${response: -3}"
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 204 ]; then
        print_success "CORS preflight request successful (HTTP $http_code)"
    else
        print_error "CORS preflight request failed (HTTP $http_code)"
    fi
}

# 测试用户登录
test_login() {
    print_test "User login"
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d '{"username": "13621096266", "password": "test"}' \
        "${API_BASE}/auth/login")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        print_success "Login successful (HTTP $http_code)"
        # 提取token
        TOKEN=$(echo "$response_body" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
        if [ -n "$TOKEN" ]; then
            print_success "Token extracted: ${TOKEN:0:20}..."
        else
            print_error "Token not found in response"
        fi
    else
        print_error "Login failed (HTTP $http_code)"
        print_info "Response: $response_body"
    fi
}

# 测试无效登录
test_invalid_login() {
    print_test "Invalid login (should fail)"
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d '{"username": "invalid", "password": "wrong"}' \
        "${API_BASE}/auth/login")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 401 ]; then
        print_success "Invalid login correctly rejected (HTTP $http_code)"
    else
        print_error "Invalid login should return 401, got $http_code"
        print_info "Response: $response_body"
    fi
}

# 测试获取票据列表（无认证）
test_tickets_without_auth() {
    print_test "Get tickets without authentication (should fail)"
    
    response=$(curl -s -w "\n%{http_code}" -X GET \
        "${API_BASE}/tickets")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 401 ]; then
        print_success "Unauthorized access correctly rejected (HTTP $http_code)"
    else
        print_error "Should require authentication, got $http_code"
        print_info "Response: $response_body"
    fi
}

# 测试获取票据列表（有认证）
test_tickets_with_auth() {
    print_test "Get tickets with authentication"
    
    if [ -z "$TOKEN" ]; then
        print_error "No authentication token available"
        return 1
    fi
    
    response=$(curl -s -w "\n%{http_code}" -X GET \
        -H "Authorization: Bearer $TOKEN" \
        "${API_BASE}/tickets")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        print_success "Get tickets successful (HTTP $http_code)"
        # 检查是否返回了数组
        if echo "$response_body" | grep -q '\['; then
            print_success "Response contains array structure"
        else
            print_error "Response does not contain expected array structure"
        fi
    else
        print_error "Get tickets failed (HTTP $http_code)"
        print_info "Response: $response_body"
    fi
}

# 测试创建票据
test_create_ticket() {
    print_test "Create new ticket"
    
    if [ -z "$TOKEN" ]; then
        print_error "No authentication token available"
        return 1
    fi
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{"title": "Test Ticket", "description": "This is a test ticket created by API test"}' \
        "${API_BASE}/tickets")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 201 ]; then
        print_success "Create ticket successful (HTTP $http_code)"
        # 提取ticket ID
        TICKET_ID=$(echo "$response_body" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        if [ -n "$TICKET_ID" ]; then
            print_success "Ticket created with ID: $TICKET_ID"
        else
            print_error "Ticket ID not found in response"
        fi
    else
        print_error "Create ticket failed (HTTP $http_code)"
        print_info "Response: $response_body"
    fi
}

# 测试删除票据
test_delete_ticket() {
    print_test "Delete ticket"
    
    if [ -z "$TOKEN" ]; then
        print_error "No authentication token available"
        return 1
    fi
    
    if [ -z "$TICKET_ID" ]; then
        print_error "No ticket ID available for deletion"
        return 1
    fi
    
    response=$(curl -s -w "\n%{http_code}" -X DELETE \
        -H "Authorization: Bearer $TOKEN" \
        "${API_BASE}/tickets/$TICKET_ID")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        print_success "Delete ticket successful (HTTP $http_code)"
    else
        print_error "Delete ticket failed (HTTP $http_code)"
        print_info "Response: $response_body"
    fi
}

# 测试无效的API端点
test_invalid_endpoint() {
    print_test "Invalid API endpoint (should return 404)"
    
    response=$(curl -s -w "\n%{http_code}" -X GET \
        "${API_BASE}/nonexistent")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 404 ]; then
        print_success "Invalid endpoint correctly returns 404 (HTTP $http_code)"
    else
        print_error "Invalid endpoint should return 404, got $http_code"
        print_info "Response: $response_body"
    fi
}

# 测试请求日志记录
test_request_logging() {
    print_test "Request logging functionality"
    
    # 发送一个简单的请求来触发日志记录
    curl -s -X GET "${BASE_URL}/static/" > /dev/null 2>&1
    
    print_success "Request sent to trigger logging"
    print_info "Check server logs for request logging output"
}

# 主测试函数
main() {
    print_header "API功能测试"
    print_info "测试目标: $BASE_URL"
    echo ""
    
    # 基础检查
    check_server
    echo ""
    
    # 基础功能测试
    test_static_files
    test_cors
    test_request_logging
    echo ""
    
    # 认证测试
    print_header "认证功能测试"
    test_login
    test_invalid_login
    echo ""
    
    # API功能测试
    print_header "API功能测试"
    test_tickets_without_auth
    test_tickets_with_auth
    test_create_ticket
    test_delete_ticket
    echo ""
    
    # 错误处理测试
    print_header "错误处理测试"
    test_invalid_endpoint
    echo ""
    
    print_header "测试完成"
    print_success "All tests completed!"
    print_info "Check server logs for detailed request/response logging"
}

# 运行测试
main "$@"
