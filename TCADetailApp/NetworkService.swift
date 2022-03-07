import Combine
import Foundation

protocol Networking {
  func get<T: Codable>(of type: T.Type, url: String) -> AnyPublisher<T, NetworkService.NetworkError>
}

final class NetworkService: Networking {
  private let session: URLSession
  private let decoder: JSONDecoder
  
  init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
    self.session = session
    self.decoder = decoder
  }
  
  func get<T: Codable>(of type: T.Type = T.self, url: String) -> AnyPublisher<T, NetworkError> {
    guard let url = URL(string: url) else {
      return Fail(error: NetworkError.invalidUrl).eraseToAnyPublisher()
    }
    
    return session.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: type, decoder: decoder)
      .mapError { NetworkError.decodeFailed($0.localizedDescription) }
      .eraseToAnyPublisher()
  }
}

extension NetworkService {
  enum NetworkError: Error {
    case invalidUrl
    case decodeFailed(String)
  }
}
