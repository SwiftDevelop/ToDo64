//
//  ToDoDetailViewModel.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ToDoDetailViewModel {
    // MARK: - Properties
    var item: ToDoItem
    var modelContext: ModelContext
    private let notificationService: NotificationService // DIP: 의존성 주입
    
    // Local Editing States (임시 저장소)
    var localTitle: String = ""
    var localContent: String = ""
    var localIsCompleted: Bool = false
    var localIsReminderOn: Bool = false
    var localReminderDate: Date = Date()
    
    // Alert States
    var showDeleteAlert: Bool = false
    var showEmptyTitleAlert: Bool = false
    
    // MARK: - Initialization
    init(item: ToDoItem, modelContext: ModelContext, notificationService: NotificationService = NotificationManager.shared) {
        self.item = item
        self.modelContext = modelContext
        self.notificationService = notificationService
        loadData()
    }
    
    // MARK: - Methods
    
    /// 원본 데이터를 로컬 상태로 로드
    func loadData() {
        localTitle = item.title
        localContent = item.content ?? ""
        localIsCompleted = item.isCompleted
        localIsReminderOn = item.isReminderOn
        localReminderDate = item.reminderDate
    }
    
    /// 변경 사항 저장 (Validation -> Update -> Notification Sync)
    /// - Returns: 저장 성공 여부 (성공 시 true 반환하여 뷰가 dismiss 되도록 함)
    /// - Note: 로컬 상태(localTitle 등)를 원본 모델(item)에 반영하고, 변경된 내용에 따라 알림을 재스케줄링합니다.
    func saveChanges() -> Bool {
        // 1. 유효성 검사: 제목은 필수 항목
        if localTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showEmptyTitleAlert = true
            return false
        }
        
        // FIXME: 저장 로직 실패 시(예: DB 에러) 처리가 누락되어 있음
        
        // 상세 메모 정제 (빈 문자열은 nil로 저장)
        let trimmedContent = localContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2. 모델 데이터 업데이트
        item.title = localTitle
        item.content = trimmedContent.isEmpty ? nil : trimmedContent
        item.isCompleted = localIsCompleted
        item.isReminderOn = localIsReminderOn
        item.reminderDate = localReminderDate
        
        // 3. 알림 시스템 동기화
        // 알림 설정 변경에 따라 스케줄링을 추가하거나 취소합니다.
        if item.isReminderOn {
            notificationService.scheduleNotification(for: item)
        } else {
            notificationService.cancelNotification(for: item)
        }
        
        return true
    }
    
    /// 아이템 삭제
    func deleteItem() {
        notificationService.cancelNotification(for: item)
        modelContext.delete(item)
    }
    
    // MARK: - Input Handling
    
    func validateTitleInput() {
        if localTitle.count > ToDoConstants.Limits.titleMaxLength {
            localTitle = String(localTitle.prefix(ToDoConstants.Limits.titleMaxLength))
        }
    }
    
    func validateContentInput() {
        if localContent.count > ToDoConstants.Limits.contentMaxLength {
            localContent = String(localContent.prefix(ToDoConstants.Limits.contentMaxLength))
        }
    }
}
