import Foundation
import XCTestDynamicOverlay

final class URLProtocolMock: URLProtocol {
  static var data: Data?
  
  static var requestSucceeded = true
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  
  override func startLoading() {
    if URLProtocolMock.requestSucceeded {
      client?.urlProtocol(self, didReceive: .init(), cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: URLProtocolMock.data ?? .init())
      client?.urlProtocolDidFinishLoading(self)
    } else {
      client?.urlProtocol(self, didFailWithError: MockError.downloadFailed)
    }
  }
  
  override func stopLoading() {}
}

extension URLProtocolMock {
  enum MockError: Error {
    case downloadFailed
  }
}
