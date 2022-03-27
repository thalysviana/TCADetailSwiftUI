import Combine
import Foundation

@testable import TCADetailApp

final class NetworkServiceSpy<Response>: Networking {
  private(set) var fetchContentCalled = false
  
  let passthroughSubject = PassthroughSubject<Any, NetworkError>()
  
  func fetchContent<T: Codable>(of type: T.Type, url: String) -> AnyPublisher<T, NetworkError> {
    fetchContentCalled = true
    return passthroughSubject.compactMap { $0 as? T }.eraseToAnyPublisher()
  }
}
