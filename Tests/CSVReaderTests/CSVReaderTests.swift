import XCTest
@testable import CSVReader

class CSVReaderTests: XCTestCase {
    
    func test_speed() throws {
        let reader = CSVReader()
        let url = Bundle.module.url(forResource: "csv/stops.txt", withExtension: nil)!
        let values = try reader.read(from: url, keys: ["stop_id", "stop_code", "stop_name", "stop_desc", "stop_lat", "stop_lon", "zone_id", "stop_url", "location_type", "parent_station", "platform_code"])
        XCTAssert(values.count == 13038)

    }
}
