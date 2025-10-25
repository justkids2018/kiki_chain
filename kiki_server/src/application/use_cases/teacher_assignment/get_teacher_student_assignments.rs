//! 老师查看学生作业用例
//! 根据老师UID聚合其所管理学生的作业信息

use serde::{Deserialize, Serialize};

use crate::domain::errors::{DomainError, Result};
use crate::domain::teacher_assignment::TeacherAssignmentQueryRepositoryArc;
use crate::infrastructure::logging::Logger;

use super::TeacherAssignmentStudentAssignmentsView;

/// 老师作业查询参数
#[derive(Debug, Deserialize)]
pub struct GetTeacherStudentAssignmentsQuery {
    pub teacher_uid: String,
}

/// 老师作业查询结果
#[derive(Debug, Serialize)]
pub struct GetTeacherStudentAssignmentsResponse {
    pub teacher_uid: String,
    pub students: Vec<TeacherAssignmentStudentAssignmentsView>,
}

/// 老师作业查询用例
pub struct GetTeacherStudentAssignmentsUseCase {
    repository: TeacherAssignmentQueryRepositoryArc,
}

impl GetTeacherStudentAssignmentsUseCase {
    pub fn new(repository: TeacherAssignmentQueryRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行查询
    pub async fn execute(
        &self,
        query: GetTeacherStudentAssignmentsQuery,
    ) -> Result<GetTeacherStudentAssignmentsResponse> {
        Logger::info("📘 [老师作业] 开始查询老师关联的学生作业信息");
        self.validate(&query)?;

        let aggregates = self
            .repository
            .find_student_assignments_by_teacher(&query.teacher_uid)
            .await?;

        let students = aggregates
            .iter()
            .map(TeacherAssignmentStudentAssignmentsView::from)
            .collect::<Vec<_>>();

        Logger::info(format!(
            "✅ [老师作业] 查询完成 - 老师: {}, 学生数量: {}",
            query.teacher_uid,
            students.len()
        ));

        Ok(GetTeacherStudentAssignmentsResponse {
            teacher_uid: query.teacher_uid,
            students,
        })
    }

    fn validate(&self, query: &GetTeacherStudentAssignmentsQuery) -> Result<()> {
        if query.teacher_uid.trim().is_empty() {
            return Err(DomainError::Validation("teacher_uid 不能为空".to_string()));
        }
        Ok(())
    }
}
