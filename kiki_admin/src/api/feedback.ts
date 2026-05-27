import request from './request'

export interface FeedbackItem {
    id: number
    user_id: string
    feedback_type: string
    content: string
    contact?: string | null
    page?: string | null
    status: 'pending' | 'processing' | 'resolved' | 'ignored'
    created_at: string
    updated_at: string
}

export const feedbackAPI = {
    list(status?: string) {
        return request.get<any, { success: boolean; data: FeedbackItem[] }>('/api/v1/admin/feedback', {
            params: status ? { status } : undefined
        })
    },

    updateStatus(id: number, status: FeedbackItem['status']) {
        return request.patch<any, { success: boolean; data: any }>(`/api/v1/admin/feedback/${id}/status`, { status })
    }
}
