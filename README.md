# CSVReader

Read and parse a .csv file which may include values with quotes which contain commas.

This is the regular expression I used:

```(?:\"([^\"]*)\",)|(?:([^,]*),)|([^,]*)```

Flaw: It does not handle the case of the final value in each line after the last comma having quotation marks.

Usage:
```
let reader = try CSVReader(url: URL, keys: [String], separator: String? = "\r\n")
let values = try reader.next(10)
```

Example:
With this .csv file:
```
first,second,third,fourth,fifth
1,2,3,4,5
6,"7,7,7",8,9,10
11,12,13,"14",15
"16,16,16","17,17,17",18,19,20
21,22,23,24,"25,25"
```
```
let url = Bundle.module.url(forResource: "csv/counts.csv", withExtension: nil)!
let reader = try CSVReader(url: url, keys: ["first", "second", "third", "fourth", "fifth"], separator: "\n")
let batch1 = try reader.next(lines: 2)
let line1 = batch1[0]
let line2 = batch1[1]
```
`line1["first"]` is `"1"`
`line2["second"]` is `"7,7,7"`
```
let batch2 = try reader.next(lines: 1)
let line3 = batch2[0]
```
`line3["fourth"]` is `"14"`

Calling `.next` with a number greater than the number of lines in the CSV won't throw an exception.

To get all lines, call `.all`.
