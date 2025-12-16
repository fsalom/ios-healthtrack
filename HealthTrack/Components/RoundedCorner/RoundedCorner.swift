//
//  RoundedCorner.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 6
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }

    // MARK: - All radius 6 configurations
    static var standard: RoundedCorner = RoundedCorner(radius: 6, corners: .allCorners)
    static var none: RoundedCorner = RoundedCorner(radius: 0, corners: .allCorners)

    static var top: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .topRight])
    static var bottom: RoundedCorner = RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight])
    static var left: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft])
    static var right: RoundedCorner = RoundedCorner(radius: 6, corners: [.topRight, .bottomRight])

    static var topLeftBottomRight: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .bottomRight])
    static var topRightBottomLeft: RoundedCorner = RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft])

    static var topLeft: RoundedCorner = RoundedCorner(radius: 6, corners: .topLeft)
    static var topRight: RoundedCorner = RoundedCorner(radius: 6, corners: .topRight)
    static var bottomLeft: RoundedCorner = RoundedCorner(radius: 6, corners: .bottomLeft)
    static var bottomRight: RoundedCorner = RoundedCorner(radius: 6, corners: .bottomRight)

    static var allExceptTopLeft: RoundedCorner = RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft, .bottomRight])
    static var allExceptTopRight: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft, .bottomRight])
    static var allExceptBottomLeft: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomRight])
    static var allExceptBottomRight: RoundedCorner = RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomLeft])
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
