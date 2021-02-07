/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	Creates a Dynamic SQL Insert Statement

	(Usage)	
					SELECT * FROM [string].[ConvertProperCaseScalar]  (@OriginalText)
	(/Usage)
##}}
*/

CREATE OR ALTER FUNCTION [string].[ConvertProperCaseScalar] (
	@OriginalText    VARCHAR(8000)
)
RETURNS VARCHAR(8000) 
BEGIN

DECLARE 
	@CleanedText    VARCHAR(8000);

WITH E01(
	[N])
	AS (SELECT 1 UNION ALL SELECT 1 UNION ALL
		SELECT 1 UNION ALL SELECT 1
		UNION ALL
		SELECT 
			1
		UNION ALL
		SELECT 
			1
		UNION ALL
		SELECT 
			1
		UNION ALL
		SELECT 
			1
		UNION ALL
		SELECT 
			1
		UNION ALL
		SELECT 
			1), --         10 or 10E01 rows
	E02(
	[N])
	AS (SELECT 
			1
		FROM 
			[E01] [a]
			, [E01] [b]), --        100 or 10E02 rows
	E04(
	[N])
	AS (SELECT 
			1
		FROM 
			[E02] [a]
			, [E02] [b]), --     10,000 or 10E04 rows
	E08(
	[N])
	AS (SELECT 
			1
		FROM 
			[E04] [a]
			, [E04] [b]), --100,000,000 or 10E08 rows
	E16(
	[N])
	AS (SELECT 
			1
		FROM 
			[E08] [a]
			, [E08] [b]), --10E16 or more rows than you'll EVER need
	Tally(
	[N])
	AS (SELECT 
			ROW_NUMBER() OVER(
			ORDER BY 
			[N])
		FROM 
			[E16])
	SELECT   
		@CleanedText = ISNULL(@CleanedText, '') + --first char is always capitalized?
						CASE
							WHEN [Tally].[N] = 1
								THEN UPPER(SUBSTRING(@OriginalText, [Tally].[N], 1))
							WHEN SUBSTRING(@OriginalText, [Tally].[N] - 1, 1) = ' '
								THEN UPPER(SUBSTRING(@OriginalText, [Tally].[N], 1))
							ELSE LOWER(SUBSTRING(@OriginalText, [Tally].[N], 1))
						END
	FROM   
		[Tally]
	WHERE [Tally].[N] <= LEN(@OriginalText);

	RETURN @CleanedText;
	END;

GO