import Combine
import Foundation

protocol Networking {
  func fetchContent<T: Codable>(of type: T.Type, url: String) -> AnyPublisher<T, NetworkError>
}

final class NetworkService: Networking {
  private let session: URLSession
  private let decoder: JSONDecoder
  
  init(session: URLSession = URLSession.shared, decoder: JSONDecoder = .init()) {
    self.session = session
    self.decoder = decoder
  }
  
  func fetchContent<T: Codable>(of type: T.Type = T.self, url: String) -> AnyPublisher<T, NetworkError> {
    guard let url = URL(string: url) else {
      return Fail(error: NetworkError.invalidUrl).eraseToAnyPublisher()
    }
    
    return session.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: type, decoder: decoder)
      .mapError { _ in NetworkError.decodeFailed }
      .eraseToAnyPublisher()
  }
}

enum NetworkError: String, Error {
  case invalidUrl
  case unknownError
  case decodeFailed
}
