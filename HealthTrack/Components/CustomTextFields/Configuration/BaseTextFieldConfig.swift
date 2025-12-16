//
//  CustomTextFieldConfig.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

class BaseTextFieldConfig {
    var keyboardType: UIKeyboardType
    var textInputAutocapitalization: TextInputAutocapitalization
    var maxLength: Int
    var submitLabel: SubmitLabel
    var lineLimitCount: Int
    var haslineLimitReservedSpace: Bool
    var axisFont: Axis
    var alignment: Alignment

    init(keyboardType: UIKeyboardType,
         textInputAutocapitalization: TextInputAutocapitalization,
         maxLength: Int,
         submitLabel: SubmitLabel,
         lineLimitCount: Int,
         haslineLimitReservedSpace: Bool = false,
         axisFont: Axis = .horizontal,
         alignment: Alignment = .center) {
        self.keyboardType = keyboardType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.maxLength = maxLength
        self.submitLabel = submitLabel
        self.lineLimitCount = lineLimitCount
        self.haslineLimitReservedSpace = haslineLimitReservedSpace
        self.axisFont = axisFont
        self.alignment = alignment
    }

    static var defaultConfig = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 999,
        submitLabel: .done,
        lineLimitCount: 1
    )

    static var search = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 999,
        submitLabel: .search,
        lineLimitCount: 1
    )

    static var email = BaseTextFieldConfig(
        keyboardType: .emailAddress,
        textInputAutocapitalization: .never,
        maxLength: 100,
        submitLabel: .done,
        lineLimitCount: 1
    )

    static var note = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 100,
        submitLabel: .done,
        lineLimitCount: 5,
        haslineLimitReservedSpace: true,
        axisFont: .vertical
    )
}
