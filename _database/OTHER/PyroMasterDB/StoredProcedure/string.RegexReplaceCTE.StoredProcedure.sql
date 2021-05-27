SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[RegexReplaceCTE]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [string].[RegexReplaceCTE] AS' 
END
GO
ALTER PROCEDURE [string].[RegexReplaceCTE]
AS

CREATE TABLE #dummyData(id int identity(1,1), teststring nvarchar(255))

INSERT INTO #dummyData(teststring)
VALUES(N'<B99_9>TEST</B99_9><LastDay>TEST</LastDay>, <B99_9>TEST</B99_9>, <B99_9></B99_9>')

DECLARE @starttag nvarchar(10) = N'<B99_9>', @endtag nvarchar(10) = N'</B99_9>'

;WITH cte AS(
    SELECT id, STUFF(
                teststring,
                PATINDEX(N'%'+@starttag+N'[a-z0-9]%',teststring)+LEN(@starttag),
                (PATINDEX(N'%[a-z0-9]'+@endtag+N'%',teststring)+1)-(PATINDEX(N'%'+@starttag+N'[a-z0-9]%',teststring)+LEN(@starttag)),
                N''
            ) as teststring, 1 as iteration
    FROM #dummyData
    -- iterate until everything is replaced
    UNION ALL
    SELECT id, STUFF(
                teststring,
                PATINDEX(N'%'+@starttag+N'[a-z0-9]%',teststring)+LEN(@starttag),
                (PATINDEX(N'%[a-z0-9]'+@endtag+N'%',teststring)+1)-(PATINDEX(N'%'+@starttag+N'[a-z0-9]%',teststring)+LEN(@starttag)),
                N''
            ) as teststring, iteration+1 as iteration
    FROM cte
    WHERE PATINDEX(N'%'+@starttag+N'[a-z0-9]%',teststring) > 0
)
SELECT c.id, c.teststring 
FROM cte as c
-- Join to get only the latest iteration
INNER JOIN (
            SELECT id, MAX(iteration) as maxIteration
            FROM cte 
            GROUP BY id
        ) as onlyMax
    ON c.id = onlyMax.id
    AND c.iteration = onlyMax.maxIteration

-- Cleanup
DROP TABLE #dummyData
GO
