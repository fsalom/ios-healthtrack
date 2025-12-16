//
//  ImportGlucoseDataUseCase.swift
//  HealthTrack
//

import Foundation

protocol ImportGlucoseDataUseCaseProtocol {
    func execute(from url: URL) throws -> [GlucoseReadingModel]
}

final class ImportGlucoseDataUseCase: ImportGlucoseDataUseCaseProtocol {

    // MARK: - Properties

    private let parser: GlucoseCSVParserProtocol

    // MARK: - Init

    init(parser: GlucoseCSVParserProtocol = GlucoseCSVParser()) {
        self.parser = parser
    }

    // MARK: - Public Methods

    func execute(from url: URL) throws -> [GlucoseReadingModel] {
        try parser.parse(from: url)
    }
}
