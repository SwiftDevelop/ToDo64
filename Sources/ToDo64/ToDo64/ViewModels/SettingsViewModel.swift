//
//  SettingsViewModel.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/09.
//

import Foundation
import UIKit
import SwiftData

@Observable
class SettingsViewModel {
    // MARK: - Properties
    
    private let backupService: BackupService
    
    /// 앱 버전 정보 (예: "1.0.0 (1)")
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    // MARK: - Initialization
    
    init(backupService: BackupService = .shared) {
        self.backupService = backupService
    }
    
    // MARK: - Actions
    
    /// 모든 데이터를 삭제합니다.
    func deleteAllData(modelContext: ModelContext) {
        backupService.deleteAllData(modelContext: modelContext)
    }
    
    /// 현재 데이터를 JSON 파일로 내보냅니다.
    /// - Returns: 생성된 JSON 파일의 URL
    func exportData(modelContext: ModelContext) -> URL? {
        return backupService.exportData(modelContext: modelContext)
    }
    
    /// JSON 파일로부터 데이터를 복원(병합)합니다.
    /// - Returns: 성공 여부
    func importData(from sourceURL: URL, modelContext: ModelContext) -> Bool {
        return backupService.importData(from: sourceURL, modelContext: modelContext)
    }
    
    /// 개발자 문의 메일 URL을 반환합니다.
    func getSupportEmailURL() -> URL? {
        let email = "support@example.com" // FIXME: 실제 개발자 이메일 주소
        let subject = "[ToDo64] 문의사항"
        let body = "\n\n---\nDevice: \(UIDevice.current.model)\nOS: \(UIDevice.current.systemVersion)\nVersion: \(appVersion)"
        
        let mailString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        return URL(string: mailString)
    }
}