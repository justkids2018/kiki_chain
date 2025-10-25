# 请求响应格式自查 Prompt

请在 리뷰 或自动化检查中，逐条验证接口返回是否严格符合 `ApiResponse` 规范。按照以下步骤执行：
使用统一的 `ApiResponse::success()` 和 `ApiResponse::error()` 方法
1. **确认结构**  
   - 顶层必须是对象，且包含固定字段：`success`, `data`, `message`, `errorcode`（失败场景必填）。  
   - 禁止新增未约定的根字段，例如 `status`、`result`、`payload` 等。

2. **成功响应检查**  
   - `success` 必须为 `true`。  
   - `data` 存放业务有效载荷，不得使用 `null`；若无数据，使用空对象或空数组。  
   - `message` 提供简洁成功描述，例如 `"操作成功"`；不得为空字符串。  
   - 不应出现 `errorcode` 字段。

3. **失败响应检查**  
   - `success` 必须为 `false`。  
   - `errorcode` 使用统一错误码体系（例如 100xx/400xx）。  
   - `message` 说明失败原因，使用可读中文/英文短句。  
   - `data` 为 `null` 或包含辅助信息（如表单字段错误列表），但不得用于返回成功数据。

4. **HTTP 状态码一致性**  
   - `2xx` 状态码 → `success: true`。  
   - `4xx/5xx` 状态码 → `success: false`。  
   - 若发现状态码与 `success` 不符，标记为异常。

5. **日志 & 中间件输出**  
   - 确认请求响应日志（如 `request_response_data_log_middleware`）打印出的响应示例同样符合上述结构。  
   - 对于返回值经过中间件包裹的情况，保证最终输出的 JSON 未被二次嵌套。

6. **常见问题清单**  
   - 返回 `string` 或 `array` 而非对象。  
   - 成功响应中遗漏 `data` 字段或填入 `null`。  
   - 失败响应未设置 `errorcode` 或 `success` 仍为 `true`。  
   - 同时包含 `error`、`errors`、`msg` 等旧字段。  
   - 直接透传第三方接口原始结构，未包裹成 `ApiResponse`。

> 审核通过标准：任意接口在所有执行路径（成功、失败、异常处理）下，返回体均符合 `ApiResponse` 模型；日志样例与接口文档示例保持一致。
