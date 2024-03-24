//
//  CSVReader.swift
//  
//
//  Created by Merch Visoiu on 2024-03-14.
//

import Foundation

public enum CSVReaderError: Error {
    case fileNotFound
    case notAString
    case noFirstLine
}


public class CSVReader {
    
    /// Represents a line in a CSV file, after the first header line.
    /// Example 1: `a,b,c,d,e`. This will produce 5 matches, with `a`, `b`, `c`, and `d` in the second group, and `e` in the third group.
    /// Example 2: `a,"b",c,d,e`. This will produce 5 matches, with `a` in the second group, `b` in the first group without quotes, `c` and `d` in the second group, and `e` in the third group.
    /// Example 3: `"a,a","b,b",c,d,e`. This will produce 5 matches, with `a,a` and `b,b` in the second group, `c` and `d` in the second group, and `e` in the third group.
    /// The `(?:)` is used to exclude the quotes in the first group, and the comma in the second group.
    /// Explanation: Match a string without quotes starting and ending with quotes separated by a comma but exclude the quotes and comma from the group, or match a string without a comma separated by a comma, or match a string without a comma until the end.
    /// THIS DOES NOT WORK IF THE LAST VALUE AFTER THE FINAL COMMA HAS QUOTATION MARKS AND AN INTERNAL COMMA.
    private let regex = try! NSRegularExpression(pattern: "(?:\"([^\"]*)\",)|(?:([^,]*),)|([^,]*)")
    
    /// The group with quotes.
    private let FIRST_RANGE = 1
    
    /// The typical group without quotes.
    private let SECOND_RANGE = 2
    
    /// The trailing value after the final comma.
    private let THIRD_RANGE = 3
    
    /// The keys in the header.
    private let keys: [String]
    
    /// Each line in the CSV after the header, and without any potentially empty lines, maybe the last line.
    private var valueLines = [String]()
    
    /// The index into each line of the key.
    private var keyToIndex = [String: Int]()
    
    /// Number of lines read into the CSV.
    private var readLines = 0
    
    
    /// Init.
    /// - Parameters:
    ///   - url: The local file.
    ///   - keys: The headers.
    ///   - separator: The whitespace characters at the end of each line, likely `\n` or `\r\n`.
    public init(url: URL, keys: [String], separator: String? = "\r\n") throws {
        self.keys = keys
        guard FileManager.default.fileExists(atPath: url.path) else { throw CSVReaderError.fileNotFound }
        
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else { throw CSVReaderError.notAString }
        let lines = string.components(separatedBy: separator!)
        guard let line = lines.first else { throw CSVReaderError.noFirstLine }
        
        /// Extract the keys from the header line.
        self.keyToIndex = extractKeysFromHeader(line: line)
        
        /// Iterate through each line in the CSV file, after the header line, to check for empty lines.
        let afterFirstLine = 1
        for i in afterFirstLine..<lines.count {
                
            /// Skip empty lines, probably just the last line.
            if lines[i] != "" {
                self.valueLines.append(lines[i])
            }
        }
    }
    
    /// Determine if there are any more lines remaining to read.
    /// - Returns: Boolean.
    public func hasNext() -> Bool {
        self.readLines < self.valueLines.count
    }
    
    /// Get all value lines in the CSV.
    /// - Returns: An array of dictionaries, each dictionary representing a line, with the key as the text from the header.
    public func all() throws -> [[String: String]] {
        try next(lines: self.valueLines.count)
    }
    
    /// Reading from the CSV is done incrementally since a very large CSV file can use a lot of memory. For example, a CSV file with 3,743,221 lines can use 23 GB of memory to convert into an array of dictionaries.
    /// - Parameter lines: The number of lines to read.
    /// - Returns: An array of dictionaries, each dictionary representing a line, with the key as the text from the header.
    public func next(lines: Int) throws -> [[String: String]] {
        var res = [[String: String]]()
        
        /// Check that the requested number of lines does not exceed the number of lines in the CSV file.
        let upto = readLines + lines > self.valueLines.count ? self.valueLines.count : readLines + lines
        
        
        for i in readLines..<upto {
            let line = self.valueLines[i]
            var newMap = [String: String]()
            let parsed = parse(line: line)
            
            newMap["trip_id"] = "parsed[0]"
            newMap["stop_id"] = "parsed[1]"
            
//            for keyString in keys {
//                guard let index = keyToIndex[keyString] else { continue }
//                guard index < parsed.count else { continue }
//                let valueString = parsed[index]
//                newMap[keyString] = valueString
//            }
            
            res.append(newMap)
            
        }
        
        /// Keep track of how many lines we've read.
        self.readLines = upto

        
        return res
    }
    
    
    /// Build a mapping of the keys from the header line to an index in order to find it on each line.
    /// - Parameter line: The header line.
    /// - Returns: A mapping for each header key to its position index.
    private func extractKeysFromHeader(line: String) -> [String: Int] {
        let lineComponents = line.components(separatedBy: ",")
        let trimmedLineComponents = lineComponents.compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines ) })
        for keyString in keys {
            let index = trimmedLineComponents.firstIndex(of: keyString)
            keyToIndex[keyString] = index
        }
        return keyToIndex
    }
    
    /// Match each line in the CSV file with the regular expression.
    private func parse(line: String) -> [String] {
        return line.components(separatedBy: ",")
//        var res = [String]()
//        let matches = regex.matches(in: line, range: NSRange(location: 0, length: line.count))
//        for match in matches {
//            
//            /// First check if it matches the quoted value, then check if it matches an unquoted value, then check if it matches the trailing value after the final comma.
//            if let range = Range(match.range(at: FIRST_RANGE), in: line) ?? Range(match.range(at: SECOND_RANGE), in: line) ?? Range(match.range(at: THIRD_RANGE), in: line) {
//                let value = line[range]
//                res.append(String(value))
//            }
//        }
//        return res
         
         
    }
}
