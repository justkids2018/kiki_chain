
Dify API 整理（获取会话历史消息）

接口说明

接口地址
GET /v1/messages

用途
按分页形式返回会话历史消息记录，第一页返回最新的 limit 条，倒序排列。

⸻

请求参数

1. Header
	•	Authorization (string, required)
	•	格式：Bearer <API_KEY>
	•	必须携带 API Key

2. Query
	•	conversation_id (string, required)
	•	会话 ID
	•	user (string, required)
	•	用户标识（由开发者自定义规则）
	•	⚠️ 注意：Service API 不共享 WebApp 创建的会话
	•	limit (int, 可选，默认 20)
	•	返回的条数
	•	first_id (string, 可选)
	•	用于分页，取某条消息的 ID 作为起点，获取该消息之前的数据

⸻

响应参数

主要字段

{
  "limit": 20,
  "has_more": true,
  "data": [
    {
      "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "conversation_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "inputs": {},
      "query": "用户提问",
      "answer": "AI 回复",
      "message_files": [
        {
          "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
          "type": "file类型",
          "url": "文件下载地址",
          "belongs_to": "user" // user 或 assistant
        }
      ],
      "feedback": {
        "rating": "like" // 或 dislike
      },
      "retriever_resources": []
    }
  ]
}

字段说明
	•	id：消息 ID
	•	conversation_id：会话 ID
	•	query：用户输入内容
	•	answer：AI 回复内容（可能是 Markdown）
	•	message_files：消息关联的文件（可选）
	•	feedback：用户反馈（like/dislike）
	•	retriever_resources：检索到的外部知识资源（可选）
	•	has_more：是否还有更多历史

⸻

cURL 示例

curl --request GET \
  --url 'http://<api_base_url>/v1/messages?conversation_id=xxxxx&user=test_user&limit=20' \
  --header 'Authorization: Bearer <API_KEY>'


⸻


