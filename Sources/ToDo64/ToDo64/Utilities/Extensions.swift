//
//  Extensions.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import SwiftUI

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // FIXME: 파싱 실패 시 명확한 에러 로그나 처리가 있으면 좋음
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// 현재 색상보다 더 어두운 색상을 반환합니다.
    /// - Parameter percentage: 어둡게 만들 비율 (0.0 ~ 1.0)
    /// - Note: HSB(Hue, Saturation, Brightness) 모델로 변환하여 밝기를 낮추고 채도를 약간 높여 가독성 좋은 진한 색을 만듭니다.
    func darker(by percentage: CGFloat = 0.3) -> Color {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        // UIColor/NSColor 변환을 통해 HSB 값을 추출
        let uiColor = NativeColor(self)
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // 밝기를 낮추고 채도를 살짝 높여서 진한 색상을 만듦
        return Color(hue: h, saturation: min(s + 0.2, 1.0), brightness: max(b - percentage, 0.0), opacity: a)
    }
}

// MARK: - View Extension

extension View {
    /// 키보드를 숨깁니다.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}