//
//  ToDoRow.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import SwiftUI

struct ToDoRow: View {
    // MARK: - Properties
    
    let item: ToDoItem
    
    /// 배경 색상
    // FIXME: 색상 계산 로직이 뷰에 포함되어 있어 성능에 영향을 줄 수 있음. ViewModel이나 Model로 이동 고려
    private var backgroundColor: Color {
        if item.isCompleted {
            return Color.gray.opacity(0.2)
        } else {
            if item.hexColor.isEmpty {
                return Color.gray.opacity(0.2)
            }
            return Color(hex: item.hexColor)
        }
    }
    
    /// 타이틀 텍스트 색상 (가장 진함)
    private var titleColor: Color {
        if item.isCompleted {
            return .secondary
        }
        return backgroundColor.darker(by: 0.6)
    }
    
    /// 보조 정보 색상 (아이콘, 알림 일시, 상세 내용용 - 중간 진함)
    private var secondaryInfoColor: Color {
        if item.isCompleted {
            return .secondary.opacity(0.6)
        }
        return backgroundColor.darker(by: 0.45)
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                // 상단 알림 정보
                if item.isReminderOn {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                        Text(item.reminderDate, format: .dateTime.month().day().hour().minute())
                    }
                    .font(.caption2.bold())
                    .foregroundColor(secondaryInfoColor) // 아이콘과 텍스트 모두 적용
                    .padding(.bottom, 2)
                }
                
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(titleColor)
                
                if let content = item.content, !content.isEmpty {
                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(secondaryInfoColor) // 상세 내용에도 적용
                }
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
