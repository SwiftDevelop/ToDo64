//
//  ToDoListViewModel.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ToDoListViewModel {
    // MARK: - Properties
    var modelContext: ModelContext
    private let notificationService: NotificationService // DIP: 의존성 주입
    
    // UI Binding States
    var newItemTitle: String = ""
    var showDeleteAlert: Bool = false
    var showLimitAlert: Bool = false
    
    // MARK: - Initialization
    init(modelContext: ModelContext, notificationService: NotificationService = NotificationManager.shared) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }
    
    // MARK: - Business Logic
    
    /// 새로운 할 일 추가
    /// - Parameter currentCount: 현재 아이템 개수 (Query는 View에 있으므로 주입받음)
    /// - Note: LocalNotification의 시스템 제한(64개)을 고려하여 아이템 생성을 제어합니다.
    func addItem(currentCount: Int) {
        let trimmedTitle = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // FIXME: 이미 존재하는 제목인지 중복 체크 로직 필요 여부 검토
        
        // 64개 제한 체크 (상수 사용)
        // iOS LocalNotification은 앱당 최대 64개의 스케줄링만 허용하므로, 데이터 무결성을 위해 생성 단계에서 제한
        guard currentCount < ToDoConstants.Limits.maxItemCount else {
            showLimitAlert = true
            return
        }
        
        // UI 반응성을 높이기 위해 애니메이션 블록 내에서 모델 추가 수행
        withAnimation {
            let newItem = ToDoItem(title: trimmedTitle)
            modelContext.insert(newItem)
            
            // 알림 설정이 켜져있다면 스케줄링 (기본값은 false지만 로직상 포함)
            if newItem.isReminderOn {
                notificationService.scheduleNotification(for: newItem)
            }
            
            // 입력창 초기화
            newItemTitle = ""
        }
    }
    
    /// 완료 여부 토글
    func toggleCompletion(for item: ToDoItem) {
        withAnimation {
            item.isCompleted.toggle()
        }
    }
    
    /// 단일 아이템 삭제
    func deleteItem(_ item: ToDoItem) {
        withAnimation {
            notificationService.cancelNotification(for: item)
            modelContext.delete(item)
        }
    }
    
    /// 인덱스로 아이템 삭제 (List swipe delete 대응)
    func deleteItems(offsets: IndexSet, items: [ToDoItem]) {
        withAnimation {
            for index in offsets {
                let itemToDelete = items[index]
                notificationService.cancelNotification(for: itemToDelete)
                modelContext.delete(itemToDelete)
            }
        }
    }
    
    /// 전체 아이템 삭제
    func deleteAllItems(items: [ToDoItem]) {
        withAnimation {
            for item in items {
                notificationService.cancelNotification(for: item)
                modelContext.delete(item)
            }
        }
    }
}
