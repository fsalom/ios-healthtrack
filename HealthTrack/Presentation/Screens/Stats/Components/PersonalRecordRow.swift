//
//  PersonalRecordRow.swift
//  HealthTrack
//

import SwiftUI

struct PersonalRecordRow: View {

    // MARK: - Properties

    let exerciseName: String
    let weight: String
    let date: String

    // MARK: - Body

    var body: some View {
        HStack {
            Text(exerciseName)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(weight)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
