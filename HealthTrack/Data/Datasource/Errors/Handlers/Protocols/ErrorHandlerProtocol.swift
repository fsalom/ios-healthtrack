import Foundation

protocol ErrorHandlerProtocol {
    func handle(_ error: Error) -> Error
}
