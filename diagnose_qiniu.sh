#!/bin/bash

echo "=== 七牛云配置诊断 ==="
echo ""

# 读取配置
source /Users/qisd/Documents/development/chain/kiki_chain/kiki_server/.env

echo "1. 当前配置:"
echo "   AccessKey: $QINIU_ACCESS_KEY"
echo "   SecretKey: ${QINIU_SECRET_KEY:0:10}...${QINIU_SECRET_KEY: -10}"
echo "   Bucket: $QINIU_BUCKET"
echo "   Domain: $QINIU_DOMAIN"
echo ""

echo "2. 配置长度检查:"
echo "   AccessKey 长度: ${#QINIU_ACCESS_KEY}"
echo "   SecretKey 长度: ${#QINIU_SECRET_KEY}"
echo "   Bucket 长度: ${#QINIU_BUCKET}"
echo ""

echo "3. 请在七牛云控制台确认:"
echo "   - 进入「个人中心」→「密钥管理」"
echo "   - 确认 AccessKey 是否为: $QINIU_ACCESS_KEY"
echo "   - 确认 SecretKey 前10位是否为: ${QINIU_SECRET_KEY:0:10}"
echo "   - 进入「对象存储」→「空间管理」"
echo "   - 确认 Bucket 名称是否为: $QINIU_BUCKET"
echo "   - 确认 Bucket 访问控制是否为「公开」"
echo ""

echo "4. 如果以上都正确，可能的问题:"
echo "   - 密钥已过期或被禁用"
echo "   - 账号欠费"
echo "   - Bucket 被删除或重命名"
echo "   - 密钥权限不足（需要上传权限）"
