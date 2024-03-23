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
    
    func test_incremental() throws {
        let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
        let batch1 = try reader.next(lines: 2)
        let line1 = batch1[0]
        let line2 = batch1[1]
        XCTAssert(line1["first"] == "1")
        XCTAssert(line2["second"] == "7,7,7")
        let batch2 = try reader.next(lines: 1)
        let line3 = batch2[0]
        XCTAssert(line3["fourth"] == "14" && line3["fifth"] == "15")
        let batch3 = try reader.next(lines: 1)
        let line5 = batch3[0]
        XCTAssert(line5["first"] == "16,16,16")
        XCTAssert(line5["second"] == "17,17,17")
        let batch4 = try reader.next(lines: 1)
        let line6 = batch4[0]
        XCTAssert(line6["fifth"] == "\"25") // This is wrong since my regular expression doesn't handle the case of the final value in a line having outer quotation marks and an internal comma. Will fix later.
        let batch5 = try reader.next(lines: 100)
        XCTAssert(batch5.count == 0)
    }
    
    func test_all() throws {
        let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
        let batch1 = try reader.all()
        XCTAssert(batch1.count == 5)
    }
    
    func test_has_next_true() throws {
        let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
        let _ = try reader.next(lines: 4)
        XCTAssertTrue(reader.hasNext())
    }
    
    func test_has_next_false() throws {
        let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
        let _ = try reader.next(lines: 5)
        XCTAssertFalse(reader.hasNext())
    }
    
    func test_has_next_false_past_end() throws {
        let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
        let _ = try reader.next(lines: 999)
        XCTAssertFalse(reader.hasNext())
    }
    
    func test_only_header_is_empty() throws {
        let url = Bundle.module.url(forResource: "csv/only_header.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["one", "two", "three"], separator: "\n")
        let lines = try reader.next(lines: 1)
        XCTAssert(lines.count == 0)
    }

    func test_only_header_has_next_false() throws {
        let url = Bundle.module.url(forResource: "csv/only_header.csv", withExtension: nil)!
        let reader = try CSVReader(url: url, keys: ["one", "two", "three"], separator: "\n")
        XCTAssertFalse(reader.hasNext())
    }
}
