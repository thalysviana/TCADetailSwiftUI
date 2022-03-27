import Foundation
import XCTest
import XCTestDynamicOverlay

final class URLProtocolMock: URLProtocol {
  private static var data: Data?
  
  static var handle: (() throws -> Data)?
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  
  override func startLoading() {
    do {
      let data = try URLProtocolMock.handle?()
      client?.urlProtocol(self, didReceive: .init(), cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data ?? .init())
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override func stopLoading() {}
}
