//
//  OpenFoodFactsApiProtocol.swift
//  HealthTrack
//

import Foundation

protocol OpenFoodFactsApiProtocol {
    func fetchProduct(barcode: String) async throws -> OpenFoodFactsProductDTO?
}
