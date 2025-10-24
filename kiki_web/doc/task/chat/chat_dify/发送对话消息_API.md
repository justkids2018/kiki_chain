👌 我帮你把 发送对话消息（chat-messages） 接口整理成标准 API 文档，和之前的「会话列表 / 历史消息」一起用。

⸻

Dify API 整理（发送对话消息）

接口说明

接口地址
POST /v1/chat-messages

用途
向某个会话发送用户输入，AI 返回回复。支持 阻塞模式 或 流式模式 (SSE)。

⸻

请求参数

1. Header
	•	Authorization (string, required)
	•	格式：Bearer <API_KEY>
	•	Content-Type: application/json

⸻

2. Body

参数名	类型	是否必填	说明
query	string	✅	用户输入内容
user	string	✅	用户标识（应用内唯一，不与 WebApp 共享）
inputs	object	可选	自定义输入（如 studentUid、teacherUid、assignmentId 等）
response_mode	string	可选	返回模式：blocking 或 streaming（默认 blocking）
conversation_id	string	可选	会话 ID，不传则新建会话
auto_generate_name	boolean	可选	是否自动生成会话名称


⸻

响应参数

阻塞模式 (blocking)

{
  "event": "message",
  "task_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "message_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "conversation_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "mode": "chat",
  "answer": "AI 回复的内容",
  "metadata": {
    "usage": {
      "prompt_tokens": 123,
      "completion_tokens": 123,
      "total_tokens": 246
    }
  }
}


⸻

流式模式 (streaming / SSE)

SSE 按事件逐步返回，每条消息以 data: 开头。

示例

data: {"event":"message","answer":"你好"}
data: {"event":"message","answer":"，我可以帮你"}
data: {"event":"message","answer":"解答问题。"}
data: [DONE]

客户端需要逐行解析：
	•	event = message → 提取 answer，拼接到当前 AI 回复
	•	data: [DONE] → 流结束

⸻

cURL 示例

curl --request POST \
  --url 'http://<api_base_url>/v1/chat-messages' \
  --header 'Authorization: Bearer <API_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{
    "query": "帮我解一道数学题",
    "user": "student_001",
    "inputs": {
      "assignmentId": "a001",
      "teacherUid": "t001"
    },
    "response_mode": "streaming",
    "auto_generate_name": true
  }'


⸻

Flutter (Dart) 示例

阻塞模式

Future<String> sendMessage(String query, String user) async {
  final url = Uri.parse('$baseUrl/v1/chat-messages');
  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "query": query,
      "user": user,
      "response_mode": "blocking",
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['answer'];
  } else {
    throw Exception("Failed: ${response.body}");
  }
}

流式模式 (SSE)


