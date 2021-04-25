declare @tmp table (STRING varchar(500))

insert into @tmp
values
 ('AA.0.HJ')
,('AABBCC.099.0')
,('0.91.JAH21')

;WITH Splitted
AS (
    SELECT STRING
        ,CAST('<x>' + REPLACE(STRING, '.', '</x><x>') + '</x>' AS XML) AS Parts
    FROM @tmp
    )
SELECT * FROM Splitted

SELECT STRING
    ,Parts.value(N'/x[1]', 'varchar(50)') AS [First]
    ,Parts.value(N'/x[2]', 'varchar(50)') AS [Second]
    ,Parts.value(N'/x[3]', 'varchar(50)') AS [Third] 
FROM Splitted;


DECLARE @lf NVARCHAR(1) = CHAR(10)
DECLARE @cr NVARCHAR(1) = CHAR(13)
DECLARE @crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @delimeter NVARCHAR(1) = ','
DECLARE @csv_clob NVARCHAR(MAX)

declare @tmp table (STRING varchar(500))
SET @csv_clob = (
	  SELECT * FROM OPENROWSET (
		BULK 'sample/csv/sample1.csv'
	,	DATA_SOURCE = 'AcAzDevelopmentSampleDataSource'
	,	SINGLE_CLOB
	)  AS tst
)

INSERT INTO @tmp
SELECT value 
		FROM STRING_SPLIT(
			@csv_clob, @lf
		)
;WITH Splitted
AS (
    SELECT STRING
        ,CAST('<x>' + REPLACE(STRING, ',', '</x><x>') + '</x>' AS XML) AS Parts
    FROM @tmp
    )
SELECT STRING
    ,Parts.value(N'/x[1]', 'varchar(50)') AS [First]
    ,Parts.value(N'/x[2]', 'varchar(50)') AS [Second]
    ,Parts.value(N'/x[3]', 'varchar(50)') AS [Third] 
FROM Splitted;




SELECT * FROM [string].[SplitStringIntoColumns]((
	
), @delimeter)