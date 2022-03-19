import Combine
import Foundation

public protocol DataTaskPublishable: AnyObject {
  func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher
}

extension URLSession: DataTaskPublishable {}
