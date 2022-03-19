import Combine
import Foundation
import XCTest

@testable import TCADetailApp

final class ImageNetworkProviderTests: XCTestCase {
  private let urlSessionMock = URLProtocolMock()
  private let cacheSpy = URLCacheSpy()
  
  private var cancellables = Set<AnyCancellable>()
  
  func testLoadURL_GivenValidURL_ShouldReturnImageData() throws {
    let url = "https://www.url.fake/test"
    
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: sessionConfiguration)
    let sut = ImageNetworkProvider(session: session, urlCache: cacheSpy)
    
    let downloadDataExpectation = expectation(description: "Expect downloaded data")
    let expectedData = Data()
    URLProtocolMock.handle = { expectedData }
    
    var receivedData: Data?
    sut.loadURL(url)
      .sink { _ in } receiveValue: { data in
        receivedData = data
        downloadDataExpectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [downloadDataExpectation], timeout: 0.1)
    
    XCTAssertEqual(receivedData, expectedData)
    XCTAssertTrue(cacheSpy.storeCachedResponseCalled)
    XCTAssertNotNil(cacheSpy.requestPassed)
  }
  
  func testLoadURL_GivenInvalidURL_ShouldReturnInvalidURLError() throws {
    let url = "😀"
    
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: sessionConfiguration)
    let sut = ImageNetworkProvider(session: session, urlCache: cacheSpy)
    
    let invalidUrlErrorExpectation = expectation(description: "Expect invalid url error")
    let expectedData = Data()
    URLProtocolMock.handle = { expectedData }
    
    var receivedError: ImageNetworkProvider.ImageNetworkError?
    sut.loadURL(url)
      .sink { failure in
        if case let .failure(error) = failure {
          receivedError = error
          invalidUrlErrorExpectation.fulfill()
        }
      } receiveValue: { _ in }
      .store(in: &cancellables)
    
    wait(for: [invalidUrlErrorExpectation], timeout: 0.1)
    
    XCTAssertEqual(receivedError, .invalidUrl)
  }
  
  func testLoadURL_GivenValidURL_WhenCachedDataExists_ShouldReturnCachedData() throws {
    let url = "https://www.url.fake/test"
    
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: sessionConfiguration)
    let sut = ImageNetworkProvider(session: session, urlCache: cacheSpy)
    
    let cachedDataExpectation = expectation(description: "Expect cached data")
    let expectedData = Data()
    
    cacheSpy.cachedURLResponseToBeReturned = .init(response: .init(), data: expectedData)
    
    var receivedData: Data?
    sut.loadURL(url)
      .sink { _ in } receiveValue: { data in
        receivedData = data
        cachedDataExpectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [cachedDataExpectation], timeout: 0.1)
    
    XCTAssertEqual(receivedData, expectedData)
  }
  
  func testLoadURL_GivenValidURL_WhenDownloadFails_ShouldReturnDownloadError() throws {
    let url = "https://www.url.fake/test"
    
    URLProtocolMock.handle = {
      throw ImageNetworkProvider.ImageNetworkError.downloadFailed("Could not finish image download")
    }
    
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: sessionConfiguration)
    let sut = ImageNetworkProvider(session: session, urlCache: cacheSpy)
    
    let downloadErrorExpectation = expectation(description: "Expect download data error")
    
    var receivedError: ImageNetworkProvider.ImageNetworkError?
    sut.loadURL(url)
      .sink { failure in
        if case let .failure(error) = failure {
          receivedError = error
        }
        downloadErrorExpectation.fulfill()
      } receiveValue: { _ in }
      .store(in: &cancellables)
    
    wait(for: [downloadErrorExpectation], timeout: 3)
    
    XCTAssertEqual(receivedError, .downloadFailed("Could not finish image download"))
  }
}
