# CSVReader

Read and parse a .csv file which may include values with quotes which contain commas.

This is the regular expression I used:

```"(?:\"(.*)\",)|(?:([^,]*),)|([^,]*)"```
