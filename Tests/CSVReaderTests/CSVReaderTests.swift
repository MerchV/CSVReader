import XCTest
@testable import CSVReader

class CSVReaderTests: XCTestCase {
    
    /// `stops.txt` has 13038 lines, after the header and minus the empty last line.
    func test_speed() throws {
        let url = Bundle.module.url(forResource: "csv/stops.txt", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["stop_id", "stop_code", "stop_name", "stop_desc", "stop_lat", "stop_lon", "zone_id", "stop_url", "location_type", "parent_station", "platform_code"])
        let values = try reader.next(lines: 13039) /// Ask for too many lines, but that shouldn't cause an index-out-of-bounds exception.
        XCTAssert(values.count == 13038)

    }
    
    /// Consumes 23 GB of memory. The file `stop_times.txt` is git ignored since it is 210 MB.
    func test_memory() throws {
        let url = Bundle.module.url(forResource: "csv/stop_times.txt", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["trip_id", "stop_id"])
        let values = try reader.next(lines: 1624557)
        XCTAssert(values.count == 1624557)

    }
}
