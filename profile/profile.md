# Profile


## Table

### Space
Total space for table data
Total space for table indexes

## Columns
Number of columns
Columns with all NULL values
Columns with all BLANK values
Columns with all NULL or BLANK valuea

## Columns

### Length
MIN(LEN)
MAX(LEN)
AVG(LEN)

#### Completeness
% NULL
% BLANK

### Value
MIN(value)
MAX(value)

### Uniqueness
COUNT(value)
COUNT(DISTINCT value)

### Decimality
SPLIT(value, '.', 1) --> Scale
SPLIT(value, '.', 2) --> Precision

### functional
convert and isdate
convert and isnumeric
convert and xxxx
try_parse
try

### Distribution
value, COUNT(1) GROUP BY value

### Cardinality

### Special
Check for special.chars
Check for trailing whitespace
Check for leading whitespace

### Searches
# of cols with '.'
# of cols with xx/xx/xx
# of cols with 000000
# of cols.with xxxx-xx-xx
# of cols with 1 or 0
# of cols with yes/no

### Meta
Type
Lenght
Precision
Scale
Nullable
