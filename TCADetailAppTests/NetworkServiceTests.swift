import Foundation
import XCTest

@testable import TCADetailApp

final class NetworkServiceTests: XCTestCase {
  
  func testGet() {
    let configuration = URLSessionConfiguration()
    configuration.protocolClasses = [URLProtocolMock.self]
    
    let session = URLSession(configuration: configuration)
    
    let sut = NetworkService(session: session)
  }
}
