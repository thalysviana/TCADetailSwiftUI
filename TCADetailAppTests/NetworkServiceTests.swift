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
    URLProtocolMock.data = try JSONEncoder().encode(photo)
    
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
}
