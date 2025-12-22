//
//  OpenFoodFactsApi.swift
//  HealthTrack
//

import Foundation

final class OpenFoodFactsApi: OpenFoodFactsApiProtocol {

    // MARK: - Properties

    private let baseURL = "https://world.openfoodfacts.org/api/v2/product"
    private let session: URLSession

    // MARK: - Init

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public Methods

    func fetchProduct(barcode: String) async throws -> OpenFoodFactsProductDTO? {
        guard let url = URL(string: "\(baseURL)/\(barcode).json") else {
            throw OpenFoodFactsError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("HealthTrack iOS App - https://github.com/healthtrack", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenFoodFactsError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenFoodFactsResponseDTO.self, from: data)

        // status == 1 means product found
        guard result.status == 1 else {
            return nil
        }

        return result.product
    }
}

// MARK: - Errors

enum OpenFoodFactsError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalida"
        case .invalidResponse:
            return "Respuesta invalida del servidor"
        case .httpError(let code):
            return "Error HTTP: \(code)"
        case .productNotFound:
            return "Producto no encontrado en la base de datos"
        }
    }
}
