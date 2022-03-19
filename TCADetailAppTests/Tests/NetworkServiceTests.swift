import Combine
import Foundation
import XCTest

@testable import TCADetailApp

final class NetworkServiceTests: XCTestCase {
  
  private var cancellables = Set<AnyCancellable>()
  
  func testFetchContent_GivenValidUrl_ShouldReturnDecodedContent() throws {
    let url = "https://www.fake.url/test"
    let photo = Photo(id: 1, title: "test", url: url)
    
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: configuration)
    URLProtocolMock.handle = {
      try JSONEncoder().encode(photo)
    }
    
    let photoExpectation = expectation(description: "Expect decoded photo")
    
    let sut = NetworkService(session: session)
    sut.fetchContent(of: Photo.self, url: url)
      .sink(receiveCompletion: { _ in }) {
        XCTAssertEqual(photo, $0)
        photoExpectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [photoExpectation], timeout: 0.1)
  }
  
  func testFetchContent_GivenInvalidUrl_ShouldReturnNeworkError() throws {
    let url = "😀"
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: configuration)
    
    let receiveCompletionExpectation = expectation(description: "Expect decode error")
    
    let sut = NetworkService(session: session)
    sut.fetchContent(of: Photo.self, url: url)
      .sink(receiveCompletion: { result in
        if case let .failure(error) = result {
          XCTAssertEqual("\(error)", "\(NetworkError.invalidUrl)")
          receiveCompletionExpectation.fulfill()
        }
      }) { _ in }
      .store(in: &cancellables)
    
    wait(for: [receiveCompletionExpectation], timeout: 0.1)
  }
  
  func testFetchContent_GivenInvalidData_ShouldReturnNeworkError() throws {
    let url = "https://www.fake.url/test"
    let dummyJSON =  "{'error': 'decodeFailed'}"
    let jsonData = dummyJSON.data(using: .utf8)
    
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: configuration)
    URLProtocolMock.handle = {
      try JSONEncoder().encode(jsonData)
    }
    
    let decodeErrorExpectation = expectation(description: "Expect decode error")
    
    let sut = NetworkService(session: session)
    sut.fetchContent(of: Photo.self, url: url)
      .sink(receiveCompletion: { result in
        if case let .failure(error) = result {
          XCTAssertEqual("\(error)", "\(NetworkError.decodeFailed)")
          decodeErrorExpectation.fulfill()
        }
      }) { _ in }
      .store(in: &cancellables)
    
    wait(for: [decodeErrorExpectation], timeout: 0.1)
  }
}
