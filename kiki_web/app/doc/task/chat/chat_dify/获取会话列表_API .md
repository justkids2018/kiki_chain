
Dify API 整理（获取会话列表）

接口说明

接口地址
GET /v1/conversations

用途
获取当前用户的会话列表，默认返回最近的 20 条。

⸻

请求参数

1. Header
	•	Authorization (string, required)
	•	格式：Bearer <API_KEY>
	•	必须携带 API Key

2. Query
	•	user (string, required)
	•	用户标识（由开发者定义规则），必须保证在应用内唯一。
	•	⚠️ 注意：Service API 创建的会话 不会和 WebApp 界面创建的共享，二者隔离。
	•	limit (int, 可选，默认 20)
	•	每次返回的数量。
	•	last_id (string, 可选，默认 null)
	•	当前页最后一条记录的 ID，用于分页（取下一页）。
	•	sort_by (string, 可选，默认 -updated_at)
	•	排序规则，比如按更新时间倒序。

⸻

响应参数

响应示例

{
  "limit": 20,
  "has_more": true,
  "data": [
    {
      "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "name": "数学作业 - 第一次会话",
      "inputs": {
        "assignmentId": "a001",
        "studentUid": "s001"
      },
      "status": "active",
      "introduction": "针对数学作业的辅导",
      "created_at": 1726800000,
      "updated_at": 1726805000
    }
  ]
}

字段说明
	•	id：会话 ID
	•	name：会话名称（可能是系统生成或用户定义）
	•	inputs：初始化时传入的参数（如 assignmentId、studentUid、teacherUid）
	•	status：会话状态（如 active）
	•	introduction：会话简介（可选）
	•	created_at：创建时间（Unix 时间戳）
	•	updated_at：最近更新时间（Unix 时间戳）
	•	has_more：是否还有更多会话

⸻

cURL 示例

curl --request GET \
  --url 'http://<api_base_url>/v1/conversations?limit=20&sort_by=-updated_at&user=test_user' \
  --header 'Authorization: Bearer <API_KEY>'


⸻

Flutter 调用示例（Dart）

Future<List<Conversation>> fetchConversations(String user, {int limit = 20, String? lastId}) async {
  final queryParams = {
    "user": user,
    "limit": "$limit",
    if (lastId != null) "last_id": lastId,
    "sort_by": "-updated_at",
  };

  final uri = Uri.http(baseUrl, "/v1/conversations", queryParams);

  final response = await http.get(
    uri,
    headers: {"Authorization": "Bearer $apiKey"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List).map((e) => Conversation.fromJson(e)).toList();
  } else {
    throw Exception("Failed to fetch conversations: ${response.body}");
  }
}





