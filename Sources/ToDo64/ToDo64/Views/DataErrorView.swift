//
//  DataErrorView.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/09.
//

import SwiftUI

struct DataErrorView: View {
    let errorMessage: String
    let onReset: () -> Void
    
    @State private var showConfirmAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .padding(.bottom, 20)
            
            VStack(spacing: 10) {
                Text("데이터 오류 발생")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("저장된 데이터를 불러오는 중 치명적인 문제가 발생했습니다.\n앱을 정상적으로 사용하려면 데이터 초기화가 필요합니다.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            if !errorMessage.isEmpty {
                ScrollView {
                    Text("Error Details: \(errorMessage)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Button {
                showConfirmAlert = true
            } label: {
                Text("데이터 초기화 및 복구")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Text("기존 데이터는 삭제되지 않고 'Corrupted_Backups' 폴더에 격리됩니다.\n문제가 지속되면 개발자에게 문의해주세요.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .alert("정말 초기화하시겠습니까?", isPresented: $showConfirmAlert) {
            Button("취소", role: .cancel) { }
            Button("초기화 실행", role: .destructive) {
                onReset()
            }
        } message: {
            Text("앱이 깨끗한 상태로 다시 시작됩니다.")
        }
    }
}
