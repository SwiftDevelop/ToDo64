//
//  ToDoConstants.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import Foundation

enum ToDoConstants {
    enum Limits {
        /// 최대 생성 가능한 할 일 개수 (LocalNotification 제한)
        // FIXME: 향후 설정이나 결제를 통해 제한 해제 기능 고려
        static let maxItemCount = 64
        
        /// 할 일 제목 최대 글자 수
        static let titleMaxLength = 40
        
        /// 상세 메모 최대 글자 수
        static let contentMaxLength = 200
    }
}
