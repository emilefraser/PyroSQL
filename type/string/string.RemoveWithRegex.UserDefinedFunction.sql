CREATE OR ALTER FUNCTION [string].[RemoveWithRegex] (
@Input NVARCHAR(4000), @Pattern VARCHAR(256))
RETURNS TABLE
AS
RETURN
    (
		WITH E1(N) AS   
		(  
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL  
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL  
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1  
		) --10E+1 or 10 rows  
		,E2(N) AS 
		(
			SELECT 1 FROM E1 a, E1 b
		) --10E+2 or 100 rows  
		,E4(N) AS 
		(
			SELECT 1 FROM E2 a, E2 b
		) --10E+4 or 10,000 rows max  
		,cteTally(N) AS   
		(  
			--==== This provides the "base" CTE and limits the number of rows right up front  
			-- for both a performance gain and prevention of accidental "overruns"  
			SELECT TOP (ISNULL(LEN(@Input),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4  
		) 
        SELECT	[Output]
        FROM
        (
			SELECT	SUBSTRING(@Input,N,1)
			FROM	cteTally
			WHERE	SUBSTRING(@Input,N,1) LIKE '%'+@Pattern+'%'
			ORDER BY N
			FOR XML PATH('')
        ) S ([Output])
    )
GO