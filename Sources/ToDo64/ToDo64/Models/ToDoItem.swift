//
//  ToDoItem.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import Foundation
import SwiftData

@Model
final class ToDoItem: Codable {
    // MARK: - Properties
    
    /// 고유 식별자 (알림 식별용)
    var id: UUID
    /// 할 일 제목
    var title: String
    /// 할 일 상세 내용 (선택 사항)
    var content: String?
    /// 생성 일시
    var createdAt: Date
    /// 알림 설정 여부
    var isReminderOn: Bool
    /// 알림 예정 일시
    var reminderDate: Date
    /// 완료 여부
    var isCompleted: Bool
    /// 배경 색상 (Hex String)
    var hexColor: String
    
    // MARK: - Initialization
    
    /// ToDoItem 초기화
    /// - Parameters:
    ///   - title: 할 일 제목
    ///   - content: 할 일 상세 내용 (기본값 nil)
    ///   - isReminderOn: 알림 활성화 여부 (기본값 false)
    ///   - reminderDate: 알림 일시 (기본값 현재 시간)
    init(title: String, content: String? = nil, isReminderOn: Bool = false, reminderDate: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.isReminderOn = isReminderOn
        self.reminderDate = reminderDate
        self.isCompleted = false
        // 랜덤 파스텔 색상 생성
        self.hexColor = ToDoItem.generateRandomPastelColor()
    }
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, createdAt, isReminderOn, reminderDate, isCompleted, hexColor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isReminderOn = try container.decode(Bool.self, forKey: .isReminderOn)
        reminderDate = try container.decode(Date.self, forKey: .reminderDate)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        hexColor = try container.decode(String.self, forKey: .hexColor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isReminderOn, forKey: .isReminderOn)
        try container.encode(reminderDate, forKey: .reminderDate)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(hexColor, forKey: .hexColor)
    }
    
    // MARK: - Helper Methods
    
    /// 랜덤 파스텔 색상 Hex 코드 생성
    static func generateRandomPastelColor() -> String {
        // FIXME: 색상 리스트를 별도 설정 파일로 분리하거나 확장이 용이하도록 구조 개선 필요
        let colors = [
            "#FFB3BA", // 파스텔 레드
            "#FFDFBA", // 파스텔 오렌지
            "#FFFFBA", // 파스텔 옐로우
            "#BAFFC9", // 파스텔 그린
            "#BAE1FF", // 파스텔 블루
            "#E6E6FA", // 라벤더
            "#FFC0CB", // 핑크
            "#FFD1DC", // 라이트 핑크
            "#E0BBE4", // 파스텔 퍼플
            "#957DAD"  // 더스티 퍼플
        ]
        return colors.randomElement() ?? "#BAE1FF"
    }
}
