SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION dbo.fn_getpropercase
( @String VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
--SET @String = 'ahmad osama' 

DECLARE @Xml XML 
DECLARE @Propercase VARCHAR(max) 
DECLARE @delimiter VARCHAR(5) 

SET @delimiter=' ' 

-- convert string to xml. replace space with node 
SET @Xml = Cast(( '<String>' 
                  + Replace(@String, @delimiter, '</String><String>') 
                  + '</String>' ) AS XML)
-- convert to proper case and 
-- concatenate column to string
;WITH cte 
     AS (SELECT a.value('.', 'varchar(max)') AS strings 
         FROM   @Xml.nodes('String') AS FN(a)) 
-- create space delimted list from the table 
-- refer to https://www.sqlservergeeks.com/create-comma-delimited-list-in-sql-server/
SELECT @ProperCase = Stuff((SELECT ' ' + Upper(LEFT(strings, 1)) 
                                   + Lower(Substring(strings, 2, Len(strings)) 
                                   ) 
                            FROM   cte 
                            FOR xml path('')), 1, 1, '') 


RETURN @ProperCase
END
GO
