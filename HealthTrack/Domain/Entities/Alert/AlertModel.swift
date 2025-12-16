//
//  Gula
//
//  AlertConfiguration.swift
//
//  Created by Rudo Apps on 6/9/25
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let style: AlertStyle

    init(title: String = "",
         message: String = "",
         style: AlertStyle = .info(action: {})) {
        self.title = title
        self.message = message
        self.style = style
    }
}
