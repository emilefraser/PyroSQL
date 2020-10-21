/* 

CASE WHEN for seasons and quarters, including validation parameter

*/
-- Need to declare year at the beginning
DECLARE @year CHAR(4)
SET @year = YEAR(getdate())
-- The CASE WHEN statement; note that 99 wll eliminate any outside parameters
CASE
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-01-01' AND @year + '-03-31' THEN 1
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-04-01' AND @year + '-06-30' THEN 2
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-07-01' AND @year + '-09-30' THEN 3
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-10-01' AND @year + '-12-31' THEN 4
	ELSE 99
END
/* EXAMPLE */
-- Create temp table
DECLARE @seasonorquarter TABLE (
	[OurDateColumn] DATE
)
-- Insert values into temp table
INSERT INTO @seasonorquarter VALUES ('2013-01-05')
INSERT INTO @seasonorquarter VALUES ('2013-04-09')
INSERT INTO @seasonorquarter VALUES ('2013-08-09')
INSERT INTO @seasonorquarter VALUES ('2013-11-05')
-- Set our year for season or quarters ranges
DECLARE @year CHAR(4)
SET @year = YEAR(getdate())
-- Select our seasons or quarters
SELECT CASE
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-01-01' AND @year + '-03-31' THEN 1
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-04-01' AND @year + '-06-30' THEN 2
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-07-01' AND @year + '-09-30' THEN 3
	WHEN CAST(OurDateColumn AS CHAR(20)) BETWEEN @year + '-10-01' AND @year + '-12-31' THEN 4
	ELSE 99
END
FROM @seasonorquarter