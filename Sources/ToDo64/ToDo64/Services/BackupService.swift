//
//  BackupService.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/09.
//

import Foundation
import SwiftData

/// 데이터 백업, 복원 및 관리를 담당하는 서비스 클래스
class BackupService {
    static let shared = BackupService()
    
    private init() {}
    
    // MARK: - Export
    
    /// 현재 데이터를 JSON 파일로 내보냅니다.
    /// - Parameter context: SwiftData Context
    /// - Returns: 생성된 JSON 파일의 URL (실패 시 nil)
    func exportData(modelContext: ModelContext) -> URL? {
        do {
            // 1. 데이터 조회: 생성일 순으로 정렬하여 일관된 백업 데이터 생성
            let descriptor = FetchDescriptor<ToDoItem>(sortBy: [SortDescriptor(\.createdAt)])
            let items = try modelContext.fetch(descriptor)
            
            // 2. JSON 인코딩 설정
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 사람이 읽기 쉽도록 포맷팅
            encoder.dateEncodingStrategy = .iso8601 // 날짜 호환성을 위해 표준 포맷 사용
            let data = try encoder.encode(items)
            
            // 3. 파일 저장 (임시 디렉토리 사용)
            // 공유 후 자동 삭제되거나 OS에 의해 관리되는 임시 폴더에 저장
            let fileManager = FileManager.default
            let tempDirectory = fileManager.temporaryDirectory
            let fileName = "ToDo64_Backup_\(Int(Date().timeIntervalSince1970)).json"
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("[BackupService] 데이터 내보내기 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Import
    
    /// JSON 파일로부터 데이터를 복원(병합)합니다.
    /// - Parameters:
    ///   - sourceURL: JSON 파일 URL
    ///   - context: SwiftData Context
    /// - Returns: 성공 여부
    func importData(from sourceURL: URL, modelContext: ModelContext) -> Bool {
        // 보안상 Sandboxed URL 접근 권한 요청
        // 외부 앱(파일 앱 등)에서 선택된 파일에 접근하기 위해서는 반드시 start/stop 호출 필요
        guard sourceURL.startAccessingSecurityScopedResource() else { return false }
        defer { sourceURL.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: sourceURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let newItems = try decoder.decode([ToDoItem].self, from: data)
            
            // 데이터 추가
            for item in newItems {
                // ID 충돌 방지를 위해 새 UUID 발급 (가져오기 모드)
                let newItem = ToDoItem(
                    title: item.title,
                    content: item.content,
                    isReminderOn: item.isReminderOn,
                    reminderDate: item.reminderDate
                )
                newItem.isCompleted = item.isCompleted
                newItem.createdAt = item.createdAt // 원본 생성일 유지
                newItem.hexColor = item.hexColor
                
                modelContext.insert(newItem)
                
                // 알림 재설정
                if newItem.isReminderOn {
                    NotificationManager.shared.scheduleNotification(for: newItem)
                }
            }
            
            return true
        } catch {
            print("[BackupService] 데이터 가져오기 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Delete
    
    /// 모든 데이터를 삭제합니다.
    func deleteAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: ToDoItem.self)
            NotificationManager.shared.cancelAllNotifications()
            print("[BackupService] 모든 데이터 및 알림 삭제 완료")
        } catch {
            print("[BackupService] 데이터 전체 삭제 실패: \(error.localizedDescription)")
        }
    }
}
