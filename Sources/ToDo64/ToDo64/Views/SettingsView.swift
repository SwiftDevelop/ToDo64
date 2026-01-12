//
//  SettingsView.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/09.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirm = false
    @State private var showFileImporter = false
    @State private var showRestoreSuccessAlert = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            // 1. 데이터 관리 섹션
            Section {
                Button {
                    shareBackupFile()
                } label: {
                    Label("데이터 백업하기", systemImage: "archivebox")
                }
                
                Button {
                    showFileImporter = true
                } label: {
                    Label("데이터 복원하기", systemImage: "arrow.clockwise.icloud")
                }
                
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("전체 데이터 삭제", systemImage: "trash")
                }
            } header: {
                Text("데이터 관리")
            } footer: {
                Text("현재 데이터를 JSON 파일로 내보내거나, 백업된 JSON 파일을 불러와 복원합니다. 복원 시 기존 데이터에 추가됩니다.")
            }
            
            // 2. 지원 섹션
            Section {
                Button {
                    openContactMail()
                } label: {
                    Label("개발자에게 문의하기", systemImage: "envelope")
                }
            } header: {
                Text("지원")
            }
            
            // 3. 앱 정보 섹션
            Section {
                HStack {
                    Label("현재 버전", systemImage: "info.circle")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("정보")
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .alert("모든 데이터 삭제", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                viewModel.deleteAllData(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("정말로 모든 할 일을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없으며, 설정된 모든 알림도 취소됩니다.")
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json], // JSON 파일만 허용
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let selectedURL = urls.first else { return }
                if viewModel.importData(from: selectedURL, modelContext: modelContext) {
                    showRestoreSuccessAlert = true
                }
            case .failure(let error):
                print("파일 선택 실패: \(error.localizedDescription)")
            }
        }
        .alert("복원 완료", isPresented: $showRestoreSuccessAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("데이터가 성공적으로 추가되었습니다.\n리스트에서 확인해보세요.")
        }
    }
    
    // MARK: - Helper Methods
    
    /// 백업 파일 공유 시트 표시
    private func shareBackupFile() {
        guard let fileURL = viewModel.exportData(modelContext: modelContext) else {
            // 파일 생성 실패 처리 (필요 시 Alert 추가)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // iPad 대응 및 현재 창 찾기
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
    
    /// 메일 앱 열기
    private func openContactMail() {
        if let url = viewModel.getSupportEmailURL() {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
