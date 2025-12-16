//
//  GlucoseImportViewModel.swift
//  HealthTrack
//

import Foundation
import UniformTypeIdentifiers

@Observable
final class GlucoseImportViewModel {

    // MARK: - Properties

    var readings: [GlucoseReadingModel] = []
    var isLoading: Bool = false
    var showingFilePicker: Bool = false
    var hasImportedData: Bool = false
    var importedFileName: String = ""

    let targetLow: Int = 70
    let targetHigh: Int = 180

    var latestReading: GlucoseReadingModel? {
        readings.first
    }

    var readingsGroupedByDay: [Date: [GlucoseReadingModel]] {
        Dictionary(grouping: readings) { reading in
            Calendar.current.startOfDay(for: reading.timestamp)
        }
    }

    var sortedDays: [Date] {
        readingsGroupedByDay.keys.sorted(by: >)
    }

    private let router: Router
    private let importUseCase: ImportGlucoseDataUseCaseProtocol

    // MARK: - Init

    init(
        router: Router,
        importUseCase: ImportGlucoseDataUseCaseProtocol = ImportGlucoseDataUseCase()
    ) {
        self.router = router
        self.importUseCase = importUseCase
    }

    // MARK: - Public Methods

    func importFile(from url: URL) {
        isLoading = true

        do {
            readings = try importUseCase.execute(from: url)
            hasImportedData = !readings.isEmpty
            importedFileName = url.lastPathComponent
        } catch {
            router.showAlert(
                title: "Error",
                message: error.localizedDescription
            )
        }

        isLoading = false
    }

    func openFilePicker() {
        showingFilePicker = true
    }

    func clearData() {
        readings = []
        hasImportedData = false
        importedFileName = ""
    }
}
