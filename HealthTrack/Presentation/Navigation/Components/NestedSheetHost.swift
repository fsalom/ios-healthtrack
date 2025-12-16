//
//  NestedSheetHost.swift
//  Gula
//
//  Created by Joan Cremades on 18/8/24.
//

import SwiftUI

struct NestedSheetHost<Content: View>: View {
    @State private var navigator: NavigatorProtocol
    private let content: Content

    init(navigator: NavigatorProtocol = Navigator.shared, content: Content) {
        self._navigator = State(initialValue: navigator)
        self.content = content
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content
        }
        .sheet(item: $navigator.nestedSheet) { nested in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                nested
            }
        }
    }
}
