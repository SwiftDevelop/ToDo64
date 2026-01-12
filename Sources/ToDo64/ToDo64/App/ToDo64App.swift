//
//  ToDo64App.swift
//  ToDo64
//
//  Created by SwiftDevelop on 1/7/26.
//

import SwiftUI
import SwiftData

@main
struct ToDo64App: App {
    // MARK: - Properties
    
    /// 데이터 컨테이너 생성 결과 저장 (성공 시 컨테이너, 실패 시 에러 객체)
    static let appDataResult: Result<ModelContainer, any Error> = {
        let schema = Schema([ToDoItem.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return .success(container)
        } catch {
            return .failure(error)
        }
    }()
    
    // MARK: - Initialization
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            switch ToDo64App.appDataResult {
            case .success(let container):
                ToDoListView()
                    .tint(.black.opacity(0.7))
                    .modelContainer(container)
            case .failure(let error):
                DataErrorView(errorMessage: error.localizedDescription, onReset: resetAppData)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// 데이터 초기화 및 복구 로직 (격리 후 종료)
    private func resetAppData() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        
        let storeFiles = ["default.store", "default.store-wal", "default.store-shm"]
        let backupDirName = "Corrupted_Backups"
        let backupDirURL = appSupportURL.appendingPathComponent(backupDirName)
        
        do {
            // 1. 백업(격리) 폴더 생성
            if !fileManager.fileExists(atPath: backupDirURL.path) {
                try fileManager.createDirectory(at: backupDirURL, withIntermediateDirectories: true)
            }
            
            // 2. 현재 타임스탬프 폴더 생성
            let timestamp = Int(Date().timeIntervalSince1970)
            let quarantineURL = backupDirURL.appendingPathComponent("\(timestamp)")
            try fileManager.createDirectory(at: quarantineURL, withIntermediateDirectories: true)
            
            // 3. 파일 이동 (격리)
            for fileName in storeFiles {
                let sourceURL = appSupportURL.appendingPathComponent(fileName)
                let destURL = quarantineURL.appendingPathComponent(fileName)
                
                if fileManager.fileExists(atPath: sourceURL.path) {
                    try fileManager.moveItem(at: sourceURL, to: destURL)
                    print("Corrupted file moved: \(fileName)")
                }
            }
            
            // 4. 앱 종료 (재실행 시 새 DB 생성 유도)
            print("데이터 격리 완료. 앱을 종료합니다.")
            exit(0)
            
        } catch {
            print("데이터 초기화 실패: \(error.localizedDescription)")
            // 이동 실패 시 삭제 시도 (최후의 수단)
            for fileName in storeFiles {
                let sourceURL = appSupportURL.appendingPathComponent(fileName)
                try? fileManager.removeItem(at: sourceURL)
            }
            exit(0)
        }
    }
}
