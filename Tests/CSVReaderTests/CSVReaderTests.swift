import XCTest
@testable import CSVReader

class CSVReaderTests: XCTestCase {
    
    func test_speed() throws { /// 1min 22s
        let reader = CSVReader()
        let url = Bundle.module.url(forResource: "csv/stop_times.txt", withExtension: nil)!
        let values = try reader.read(from: url, keys: ["trip_id", "stop_id"])
        XCTAssert(values.count == 3742960)

    }
}
