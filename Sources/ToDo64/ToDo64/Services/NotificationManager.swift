//
//  NotificationManager.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import Foundation
import UserNotifications

/// 알림 서비스 추상화 프로토콜 (DIP 준수)
protocol NotificationService {
    func requestAuthorization()
    func scheduleNotification(for item: ToDoItem)
    func cancelNotification(for item: ToDoItem)
    func cancelAllNotifications()
}

class NotificationManager: NotificationService {
    // MARK: - Properties
    
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Methods
    
    /// 알림 권한 요청
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print("알림 권한 허용 여부: \(granted)")
                // FIXME: 권한 거부 시 사용자에게 설정으로 이동하도록 안내하는 UI/로직 필요
            }
        }
    }
    
    /// 알림 스케줄링
    /// - Parameter item: 알림을 설정할 ToDoItem
    func scheduleNotification(for item: ToDoItem) {
        // 알림이 꺼져있거나 이미 지난 시간인 경우 스케줄링하지 않음 (단, 지난 시간이어도 설정을 원할 수 있으므로 시간 체크는 로직에 따라 유연하게)
        guard item.isReminderOn else { return }
        
        // 권한 확인
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.title = item.title
            if let body = item.content {
                content.body = body
            }
            content.sound = .default
            
            // 날짜 기반 트리거 생성
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // 고유 ID를 사용하여 요청 생성
            let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
            
            // 알림 센터에 추가
            self.center.add(request) { error in
                if let error = error {
                    print("알림 스케줄링 실패: \(error.localizedDescription)")
                    // FIXME: 알림 등록 실패 시 사용자에게 알림을 주거나 재시도하는 로직 필요
                } else {
                    print("알림 예약 성공: \(item.title) at \(item.reminderDate)")
                }
            }
        }
    }
    
    /// 알림 취소
    /// - Parameter item: 알림을 취소할 ToDoItem
    func cancelNotification(for item: ToDoItem) {
        center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        print("알림 취소됨: \(item.title)")
    }
    
    /// 모든 알림 취소 (디버깅용)
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
