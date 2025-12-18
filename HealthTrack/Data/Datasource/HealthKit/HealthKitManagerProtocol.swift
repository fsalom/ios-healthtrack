//
//  HealthKitManagerProtocol.swift
//  HealthTrack
//

import Foundation
import HealthKit

protocol HealthKitManagerProtocol {
    var isAvailable: Bool { get }
    var isAuthorized: Bool { get }

    func requestAuthorization() async throws
    func fetchHourlySteps(from startDate: Date, to endDate: Date) async throws -> [HourlyActivityModel]
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [WorkoutModel]
}
