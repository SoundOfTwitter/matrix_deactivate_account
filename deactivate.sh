#!/bin/bash
read -p "请输入管理员用户名: " admin_account
read -p "请输入该管理员密码: " admin_passwd
read -p "请输入域名: " matrix_domain
read -p "请输入待停用的用户名: " user_to_delete

# 获取访问令牌
response=$(curl -s -X POST -d "{\"type\":\"m.login.password\",\"user\":\"$admin_account\",\"password\":\"$admin_passwd\"}" 'http://localhost:8008/_matrix/client/r0/login')

# 提取访问令牌
access_token=$(echo $response | jq -r .access_token)

if [ "$access_token" != "null" ]; then
  echo "获取的访问令牌: $access_token"

  # 停用用户
  deactivate_response=$(curl -s -X POST "http://localhost:8008/_synapse/admin/v1/deactivate/@$user_to_delete:$matrix_domain" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-Type: application/json" \
    -d '{}')

  echo "停用用户响应: $deactivate_response"

  # 删除用户的账户数据
  # delete_response=$(curl -s -X DELETE "http://localhost:8008/_synapse/admin/v1/users/@$user_to_delete:$matrix_domain" \
  #   -H "Authorization: Bearer $access_token" \
  #   -H "Content-Type: application/json")

  # echo "删除用户响应: $delete_response"

  # 查看所有用户并提取 displayname 字段
  response=$(curl -s -X GET "http://localhost:8008/_synapse/admin/v2/users" \
       -H "Authorization: Bearer $access_token")

  # 打印原始响应以进行调试
  # echo "原始响应: $response"

  # 使用 jq 提取 displayname 并显示在终端上
  echo $response | jq -r '.users[] | .displayname'

else
  echo "无法获取访问令牌，请检查管理员账户和密码。"
fi
