import Combine
import ComposableArchitecture
import Foundation
import XCTest

@testable import TCADetailApp

final class AlbumClientTests: XCTestCase {

  var cancellable: AnyCancellable?

  func testFetchAlbums_WhenDownloadSucceeds() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [URLProtocolMock.self]

    let session = URLSession(configuration: configuration)
    let albumClient = AlbumClient(service: NetworkService(session: session))
    let photo = Photo(id: 1, title: "Title", url: "https://www.fake.url/test")
    
    URLProtocolMock.handle = {
      try JSONEncoder().encode([photo])
    }

    let expectation = expectation(description: "Expect no photos")
    
    var expectedPhotos: [Photo]?
    
    cancellable = albumClient
      .fetchAlbums()
      .sink(receiveValue: { photos in
        expectedPhotos = photos
        expectation.fulfill()
      })
    
    wait(for: [expectation], timeout: 0.1)
    
    XCTAssertEqual(expectedPhotos, [photo])
  }
  
  func testFetchAlbums_WhenDownloadFails() {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [URLProtocolMock.self]

    let session = URLSession(configuration: configuration)
    let albumClient = AlbumClient(service: NetworkService(session: session))

    let expectation = expectation(description: "Expect no photos")
    
    var expectedPhotos: [Photo]?
    
    cancellable = albumClient
      .fetchAlbums()
      .sink(receiveValue: { photos in
        expectedPhotos = photos
        expectation.fulfill()
      })
    
    wait(for: [expectation], timeout: 0.1)
    
    XCTAssertEqual(expectedPhotos, [])
  }
}
