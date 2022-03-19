import Foundation

@testable import TCADetailApp

final class URLCacheSpy: URLCacheable {
  private(set) var storeCachedResponseCalled = false
  private(set) var cachedResponseCalled = false
  
  private(set) var cachedURLResponsePassed: CachedURLResponse?
  private(set) var requestPassed: URLRequest?
  
  var cachedURLResponseToBeReturned: CachedURLResponse?
  
  init() {}
  
  func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
     cachedURLResponsePassed = cachedResponse
    requestPassed = request
    storeCachedResponseCalled = true
  }
  
  func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
    cachedResponseCalled = true
    requestPassed = request
    return cachedURLResponseToBeReturned
  }
}
