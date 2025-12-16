import Foundation

protocol DetailErrorProtocol: Error, Equatable {
    var title: String { get }
    var message: String { get }
}
