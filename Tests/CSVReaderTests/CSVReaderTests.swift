import XCTest
@testable import CSVReader

class CSVReaderTests: XCTestCase {
    
    func test_csv_reader() throws {
        let reader = CSVReader()
        let url = Bundle.module.url(forResource: "csv/stops.txt", withExtension: nil)!
        let values = try  reader.read(from: url)
        XCTAssert(values.count == 13038)
    }
}
