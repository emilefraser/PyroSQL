CREATE OR ALTER FUNCTION string.SeekInString (
    @str       NVARCHAR(4000),
    @substr    NVARCHAR(4000),
    @start     INT,
    @Occurance INT
)
RETURNS TABLE
AS

RETURN
    WITH Tally(N) AS
    (
        SELECT TOP (LEN(@str)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0)) a(N)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(N)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(N)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) d(N)
    )
, Find_N_STR AS
    (
    SELECT
    CASE WHEN DENSE_RANK() OVER(PARTITION BY @substr ORDER BY (CHARINDEX(@substr, @str, N))) = @Occurance
         THEN MAX(N - @start + 1) OVER (PARTITION BY CHARINDEX(@substr, @str, N))
         ELSE 0
         END [Loc]
    FROM dbo.Number
    WHERE CHARINDEX(@substr, @str, N) > 0
    )
    SELECT Loc= MAX(Loc)
    FROM Find_N_STR
    WHERE Loc > 0;
GO
