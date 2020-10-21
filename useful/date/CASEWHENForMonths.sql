/*

Purpose: SQL File for numbering the months, if you're column is in the year this CASE WHEN will change it to a number

Notes:
- The 99 allows use to identify anything that isn't a valid month.

*/

-- Version 1: 1 or 2 digit months
CASE 
	WHEN [OurColumnName] LIKE '%January%' THEN 1 
	WHEN [OurColumnName] LIKE '%February%' THEN 2
	WHEN [OurColumnName] LIKE '%March%' THEN 3
	WHEN [OurColumnName] LIKE '%April%' THEN 4
	WHEN [OurColumnName] LIKE '%May%' THEN 5
	WHEN [OurColumnName] LIKE '%June%' THEN 6
	WHEN [OurColumnName] LIKE '%July%' THEN 7
	WHEN [OurColumnName] LIKE '%August%' THEN 8
	WHEN [OurColumnName] LIKE '%September%' THEN 9
	WHEN [OurColumnName] LIKE '%October%' THEN 10
	WHEN [OurColumnName] LIKE '%November%' THEN 11
	WHEN [OurColumnName] LIKE '%December%' THEN 12
	ELSE 99 -- This will be removed
END

-- Version 2: 2 digit months
CASE 
	WHEN [OurColumnName] LIKE '%January%' THEN 01 
	WHEN [OurColumnName] LIKE '%February%' THEN 02
	WHEN [OurColumnName] LIKE '%March%' THEN 03
	WHEN [OurColumnName] LIKE '%April%' THEN 04
	WHEN [OurColumnName] LIKE '%May%' THEN 05
	WHEN [OurColumnName] LIKE '%June%' THEN 06
	WHEN [OurColumnName] LIKE '%July%' THEN 07
	WHEN [OurColumnName] LIKE '%August%' THEN 08
	WHEN [OurColumnName] LIKE '%September%' THEN 09
	WHEN [OurColumnName] LIKE '%October%' THEN 10
	WHEN [OurColumnName] LIKE '%November%' THEN 11
	WHEN [OurColumnName] LIKE '%December%' THEN 12
	ELSE 99 -- This will be removed
END

-- Version 3: Short months 1 digits months
CASE 
	WHEN [OurColumnName] LIKE '%Jan%' THEN 1 
	WHEN [OurColumnName] LIKE '%Feb%' THEN 2
	WHEN [OurColumnName] LIKE '%Mar%' THEN 3
	WHEN [OurColumnName] LIKE '%April%' THEN 4
	WHEN [OurColumnName] LIKE '%May%' THEN 5
	WHEN [OurColumnName] LIKE '%June%' THEN 6
	WHEN [OurColumnName] LIKE '%July%' THEN 7
	WHEN [OurColumnName] LIKE '%Aug%' THEN 8
	WHEN [OurColumnName] LIKE '%Sep%' THEN 9
	WHEN [OurColumnName] LIKE '%Oct%' THEN 10
	WHEN [OurColumnName] LIKE '%Nov%' THEN 11
	WHEN [OurColumnName] LIKE '%Dec%' THEN 12
	ELSE 99 -- This will be removed
END

-- Version 4: Short months 2 digits months
CASE 
	WHEN [OurColumnName] LIKE '%Jan%' THEN 01 
	WHEN [OurColumnName] LIKE '%Feb%' THEN 02
	WHEN [OurColumnName] LIKE '%Mar%' THEN 03
	WHEN [OurColumnName] LIKE '%April%' THEN 04
	WHEN [OurColumnName] LIKE '%May%' THEN 05
	WHEN [OurColumnName] LIKE '%June%' THEN 06
	WHEN [OurColumnName] LIKE '%July%' THEN 07
	WHEN [OurColumnName] LIKE '%Aug%' THEN 08
	WHEN [OurColumnName] LIKE '%Sep%' THEN 09
	WHEN [OurColumnName] LIKE '%Oct%' THEN 10
	WHEN [OurColumnName] LIKE '%Nov%' THEN 11
	WHEN [OurColumnName] LIKE '%Dec%' THEN 12
	ELSE 99 -- This will be removed
END

/* EXAMPLE: */

DECLARE @month TABLE(
	OurColumnName VARCHAR(12)
)
-- Insert each month into the table
INSERT INTO @month VALUES ('January')
INSERT INTO @month VALUES ('February')
INSERT INTO @month VALUES ('March')
INSERT INTO @month VALUES ('April')
INSERT INTO @month VALUES ('May')
INSERT INTO @month VALUES ('June')
INSERT INTO @month VALUES ('July')
INSERT INTO @month VALUES ('August')
INSERT INTO @month VALUES ('September')
INSERT INTO @month VALUES ('October')
INSERT INTO @month VALUES ('November')
INSERT INTO @month VALUES ('December')
INSERT INTO @month VALUES ('BadMonth')
-- Select 1 or 2 digit months
SELECT CASE 
	WHEN OurColumnName LIKE '%January%' THEN 1 
	WHEN OurColumnName LIKE '%February%' THEN 2
	WHEN OurColumnName LIKE '%March%' THEN 3
	WHEN OurColumnName LIKE '%April%' THEN 4
	WHEN OurColumnName LIKE '%May%' THEN 5
	WHEN OurColumnName LIKE '%June%' THEN 6
	WHEN OurColumnName LIKE '%July%' THEN 7
	WHEN OurColumnName LIKE '%August%' THEN 8
	WHEN OurColumnName LIKE '%September%' THEN 9
	WHEN OurColumnName LIKE '%October%' THEN 10
	WHEN OurColumnName LIKE '%November%' THEN 11
	WHEN OurColumnName LIKE '%December%' THEN 12
	ELSE 99 -- This will be removed
END
FROM @month
-- Select 2 digit months
SELECT CASE 
	WHEN OurColumnName LIKE '%January%' THEN 01 
	WHEN OurColumnName LIKE '%February%' THEN 02
	WHEN OurColumnName LIKE '%March%' THEN 03
	WHEN OurColumnName LIKE '%April%' THEN 04
	WHEN OurColumnName LIKE '%May%' THEN 05
	WHEN OurColumnName LIKE '%June%' THEN 06
	WHEN OurColumnName LIKE '%July%' THEN 07
	WHEN OurColumnName LIKE '%August%' THEN 08
	WHEN OurColumnName LIKE '%September%' THEN 09
	WHEN OurColumnName LIKE '%October%' THEN 10
	WHEN OurColumnName LIKE '%November%' THEN 11
	WHEN OurColumnName LIKE '%December%' THEN 12
	ELSE 99 -- This will be removed
END
FROM @month