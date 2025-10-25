use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use serde::Serialize;
use serde_json::{Map, Value};
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};

/// 用户实体
/// 代表系统中的用户，包含用户的所有基本信息和行为
#[derive(Debug, Clone, Serialize)]
pub struct User {
    id: Uuid,
    uid: String, //
    name: String,
    email: String,
    pwd: String,
    phone: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    role_id: i32,
}

impl User {
    // 增加to String
    pub fn to_string(&self) -> String {
        format!(
            "User {{ id: {}, uid: {}, name: {}, email: {}, phone: {}, created_at: {}, updated_at: {}, role_id: {} }}",
            self.id,
            self.uid,
            self.name,
            self.email,
            self.phone,
            self.created_at,
            self.updated_at,
            self.role_id
        )
    }

    /// 创建新用户
    pub fn new(
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        role_id: i32,
    ) -> Result<Self> {
        if name.trim().is_empty() {
            return Err(DomainError::Validation("用户名不能为空".to_string()));
        }
        if pwd.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        if uid.trim().is_empty() && phone.trim().is_empty() {
            return Err(DomainError::Validation(
                "邮箱和手机号不能同时为空".to_string(),
            ));
        }
        let now = Utc::now();
        Ok(Self {
            id: Uuid::new_v4(), // 生成新的UUID
            uid,
            name,
            email,
            pwd,
            phone,
            created_at: now,
            updated_at: now,
            role_id,
        })
    }
    pub fn reconstruct(
        id: Uuid,
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
        role_id: i32,
    ) -> Result<Self> {
        Ok(Self {
            id,
            uid,
            name,
            email,
            pwd,
            phone,
            created_at,
            updated_at,
            role_id,
        })
    }
    pub fn update_timestamp(&mut self) {
        self.updated_at = Utc::now();
    }
    /// 更新密码
    pub fn update_password(&mut self, new_pwd: String) -> Result<()> {
        if new_pwd.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        self.pwd = new_pwd;
        self.updated_at = Utc::now();
        Ok(())
    }
    /// 更新邮箱
    pub fn update_uid(&mut self, new_uid: String) {
        self.uid = new_uid;
        self.updated_at = Utc::now();
    }
    /// 更新手机号
    pub fn update_phone(&mut self, new_phone: String) {
        self.phone = new_phone;
        self.updated_at = Utc::now();
    }
    pub fn id(&self) -> Uuid {
        self.id
    }
    pub fn uid(&self) -> &str {
        &self.uid
    }
    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn email(&self) -> &str {
        &self.email
    }
    pub fn pwd(&self) -> &str {
        &self.pwd
    }
    pub fn phone(&self) -> &str {
        &self.phone
    }
    pub fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }
    pub fn updated_at(&self) -> DateTime<Utc> {
        self.updated_at
    }
    pub fn role_id(&self) -> i32 {
        self.role_id
    }
}

/// 作业实体
/// 代表老师创建的作业，包含作业的所有信息和状态
#[derive(Debug, Clone)]
pub struct Assignment {
    id: Uuid,
    teacher_id: String,
    title: String,
    description: String,
    knowledge_points: String,
    status: AssignmentStatus,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

/// 作业状态枚举
#[derive(Debug, Clone, PartialEq)]
pub enum AssignmentStatus {
    Draft,     // 草稿
    Published, // 已发布
    Archived,  // 已归档
}

impl std::fmt::Display for AssignmentStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AssignmentStatus::Draft => write!(f, "draft"),
            AssignmentStatus::Published => write!(f, "published"),
            AssignmentStatus::Archived => write!(f, "archived"),
        }
    }
}

impl Default for AssignmentStatus {
    fn default() -> Self {
        AssignmentStatus::Draft
    }
}

impl std::str::FromStr for AssignmentStatus {
    type Err = String;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "draft" => Ok(AssignmentStatus::Draft),
            "published" => Ok(AssignmentStatus::Published),
            "archived" => Ok(AssignmentStatus::Archived),
            _ => Err(format!("无效的作业状态: {}", s)),
        }
    }
}

impl Assignment {
    /// 创建新作业
    pub fn new(
        id: Uuid,
        teacher_id: String,
        title: String,
        description: String,
        knowledge_points: String,
        status: AssignmentStatus,
    ) -> Self {
        let now = Utc::now();
        Self {
            id,
            teacher_id,
            title,
            description,
            knowledge_points,
            status,
            created_at: now,
            updated_at: now,
        }
    }

    /// 重构已有作业（从数据库读取）
    pub fn reconstruct(
        id: Uuid,
        teacher_id: String,
        title: String,
        description: String,
        knowledge_points: String,
        status: AssignmentStatus,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
    ) -> Self {
        Self {
            id,
            teacher_id,
            title,
            description,
            knowledge_points,
            status,
            created_at,
            updated_at,
        }
    }

    /// 更新标题
    pub fn update_title(&mut self, title: String) -> Result<()> {
        if title.trim().is_empty() {
            return Err(DomainError::Validation("作业标题不能为空".to_string()));
        }
        if title.len() > 255 {
            return Err(DomainError::Validation("作业标题过长".to_string()));
        }
        self.title = title;
        self.updated_at = Utc::now();
        Ok(())
    }

    /// 更新描述
    pub fn update_description(&mut self, description: String) {
        self.description = description;
        self.updated_at = Utc::now();
    }

    /// 更新知识点
    pub fn update_knowledge_points(&mut self, knowledge_points: String) -> Result<()> {
        if knowledge_points.trim().is_empty() {
            return Err(DomainError::Validation("知识点不能为空".to_string()));
        }
        self.knowledge_points = knowledge_points;
        self.updated_at = Utc::now();
        Ok(())
    }

    /// 更新状态
    pub fn update_status(&mut self, status: AssignmentStatus) {
        self.status = status;
        self.updated_at = Utc::now();
    }

    // Getter方法
    pub fn id(&self) -> &Uuid {
        &self.id
    }
    pub fn teacher_id(&self) -> &str {
        &self.teacher_id
    }
    pub fn title(&self) -> &str {
        &self.title
    }
    pub fn description(&self) -> &str {
        &self.description
    }
    pub fn knowledge_points(&self) -> &str {
        &self.knowledge_points
    }
    pub fn status(&self) -> &AssignmentStatus {
        &self.status
    }
    pub fn created_at(&self) -> &DateTime<Utc> {
        &self.created_at
    }
    pub fn updated_at(&self) -> &DateTime<Utc> {
        &self.updated_at
    }
}

/// 学生作业实体
/// 代表学生与作业的关联关系，包含完成状态和评分信息
#[derive(Debug, Clone)]
pub struct StudentAssignment {
    id: Uuid,
    assignment_id: Uuid,
    student_id: String,
    status: StudentAssignmentStatus,
    dialog_rounds: i32,
    avg_thinking_time_ms: i64,
    knowledge_mastery_score: BigDecimal,
    thinking_depth_score: BigDecimal,
    evaluation_metrics: Value,
    conversation_id: Option<String>,
    started_at: Option<DateTime<Utc>>,
    completed_at: Option<DateTime<Utc>>,
}

/// 学生作业状态枚举
#[derive(Debug, Clone, PartialEq)]
pub enum StudentAssignmentStatus {
    NotStarted, // 未开始
    InProgress, // 进行中
    Completed,  // 已完成
    Reviewed,   // 已评审
}

impl std::fmt::Display for StudentAssignmentStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            StudentAssignmentStatus::NotStarted => write!(f, "not_started"),
            StudentAssignmentStatus::InProgress => write!(f, "in_progress"),
            StudentAssignmentStatus::Completed => write!(f, "completed"),
            StudentAssignmentStatus::Reviewed => write!(f, "reviewed"),
        }
    }
}

impl Default for StudentAssignmentStatus {
    fn default() -> Self {
        StudentAssignmentStatus::NotStarted
    }
}

impl std::str::FromStr for StudentAssignmentStatus {
    type Err = String;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "not_started" => Ok(StudentAssignmentStatus::NotStarted),
            "in_progress" => Ok(StudentAssignmentStatus::InProgress),
            "completed" => Ok(StudentAssignmentStatus::Completed),
            "reviewed" => Ok(StudentAssignmentStatus::Reviewed),
            _ => Err(format!("无效的学生作业状态: {}", s)),
        }
    }
}

impl StudentAssignment {
    pub const EVALUATION_METRIC_KEYS: [&'static str; 4] = [
        "three_student_rate",
        "three_proposition_quality",
        "two_student_chain",
        "two_cover_rate",
    ];

    pub fn default_evaluation_metrics() -> Value {
        let mut map = Map::new();
        for key in Self::EVALUATION_METRIC_KEYS {
            map.insert(key.to_string(), Value::Null);
        }
        Value::Object(map)
    }

    fn sanitize_evaluation_metrics(metrics: Value) -> Value {
        match metrics {
            Value::Object(mut map) => {
                for key in Self::EVALUATION_METRIC_KEYS {
                    map.entry(key.to_string()).or_insert(Value::Null);
                }
                Value::Object(map)
            }
            _ => Self::default_evaluation_metrics(),
        }
    }

    /// 创建新的学生作业
    pub fn new(
        id: Uuid,
        assignment_id: Uuid,
        student_id: String,
        status: StudentAssignmentStatus,
        dialog_rounds: i32,
        avg_thinking_time_ms: i64,
        knowledge_mastery_score: BigDecimal,
        thinking_depth_score: BigDecimal,
        evaluation_metrics: Value,
        conversation_id: Option<String>,
    ) -> Self {
        let evaluation_metrics = Self::sanitize_evaluation_metrics(evaluation_metrics);
        Self {
            id,
            assignment_id,
            student_id,
            status,
            dialog_rounds,
            avg_thinking_time_ms,
            knowledge_mastery_score,
            thinking_depth_score,
            evaluation_metrics,
            conversation_id,
            started_at: None,
            completed_at: None,
        }
    }

    /// 重构已有学生作业（从数据库读取）
    pub fn reconstruct(
        id: Uuid,
        assignment_id: Uuid,
        student_id: String,
        status: StudentAssignmentStatus,
        dialog_rounds: i32,
        avg_thinking_time_ms: i64,
        knowledge_mastery_score: BigDecimal,
        thinking_depth_score: BigDecimal,
        evaluation_metrics: Value,
        conversation_id: Option<String>,
        started_at: Option<DateTime<Utc>>,
        completed_at: Option<DateTime<Utc>>,
    ) -> Self {
        let evaluation_metrics = Self::sanitize_evaluation_metrics(evaluation_metrics);
        Self {
            id,
            assignment_id,
            student_id,
            status,
            dialog_rounds,
            avg_thinking_time_ms,
            knowledge_mastery_score,
            thinking_depth_score,
            evaluation_metrics,
            conversation_id,
            started_at,
            completed_at,
        }
    }

    /// 开始作业
    pub fn start_assignment(&mut self) {
        self.status = StudentAssignmentStatus::InProgress;
        self.started_at = Some(Utc::now());
    }

    /// 完成作业
    pub fn complete_assignment(&mut self) {
        self.status = StudentAssignmentStatus::Completed;
        self.completed_at = Some(Utc::now());
    }

    /// 更新会话ID
    pub fn update_conversation_id(&mut self, conversation_id: Option<String>) {
        self.conversation_id = conversation_id;
    }

    /// 更新评分
    pub fn update_scores(
        &mut self,
        knowledge_mastery_score: BigDecimal,
        thinking_depth_score: BigDecimal,
    ) {
        self.knowledge_mastery_score = knowledge_mastery_score;
        self.thinking_depth_score = thinking_depth_score;
    }

    // Getter方法
    pub fn id(&self) -> &Uuid {
        &self.id
    }
    pub fn assignment_id(&self) -> &Uuid {
        &self.assignment_id
    }
    pub fn student_id(&self) -> &str {
        &self.student_id
    }
    pub fn status(&self) -> &StudentAssignmentStatus {
        &self.status
    }
    pub fn dialog_rounds(&self) -> i32 {
        self.dialog_rounds
    }
    pub fn avg_thinking_time_ms(&self) -> i64 {
        self.avg_thinking_time_ms
    }
    pub fn knowledge_mastery_score(&self) -> &BigDecimal {
        &self.knowledge_mastery_score
    }
    pub fn thinking_depth_score(&self) -> &BigDecimal {
        &self.thinking_depth_score
    }
    pub fn evaluation_metrics(&self) -> &Value {
        &self.evaluation_metrics
    }
    pub fn conversation_id(&self) -> &Option<String> {
        &self.conversation_id
    }
    pub fn started_at(&self) -> &Option<DateTime<Utc>> {
        &self.started_at
    }
    pub fn completed_at(&self) -> &Option<DateTime<Utc>> {
        &self.completed_at
    }

    /// 设置作业状态
    /// 用于业务用例根据外部输入直接指定状态
    pub fn set_status(&mut self, status: StudentAssignmentStatus) {
        self.status = status;
    }

    /// 更新对话轮次统计
    pub fn set_dialog_rounds(&mut self, dialog_rounds: i32) {
        self.dialog_rounds = dialog_rounds;
    }

    /// 更新平均思考时长（毫秒）
    pub fn set_avg_thinking_time_ms(&mut self, avg_thinking_time_ms: i64) {
        self.avg_thinking_time_ms = avg_thinking_time_ms;
    }

    /// 更新知识掌握评分
    pub fn set_knowledge_mastery_score(&mut self, score: BigDecimal) {
        self.knowledge_mastery_score = score;
    }

    /// 更新思维深度评分
    pub fn set_thinking_depth_score(&mut self, score: BigDecimal) {
        self.thinking_depth_score = score;
    }

    /// 更新评估指标(JSON)
    pub fn set_evaluation_metrics(&mut self, metrics: Value) {
        self.evaluation_metrics = Self::sanitize_evaluation_metrics(metrics);
    }

    /// 设置作业开始时间
    pub fn set_started_at(&mut self, started_at: Option<DateTime<Utc>>) {
        self.started_at = started_at;
    }

    /// 设置作业完成时间
    pub fn set_completed_at(&mut self, completed_at: Option<DateTime<Utc>>) {
        self.completed_at = completed_at;
    }
}
