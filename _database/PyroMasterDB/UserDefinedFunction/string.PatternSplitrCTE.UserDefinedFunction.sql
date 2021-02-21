SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[PatternSplitrCTE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- PatternSplitrCTE will split a string based on a pattern of the form
-- supported by LIKE and PATINDEX
--
-- Created by: Dwain Camps 11-Oct-2012
CREATE FUNCTION [string].[PatternSplitrCTE]
        (@String                    VARCHAR(8000)      -- The string to be split
        ,@Pattern                   VARCHAR(500))     -- The pattern to split
RETURNS TABLE WITH SCHEMABINDING AS
RETURN
-- Note that this is an in-line Table Valued Function (iTVF)
WITH PatternSplitter AS (
    -- PatternSplitter is a recursive CTE - here is the anchor leg:
    SELECT ItemNumber=CASE WHEN @String IS NULL THEN NULL ELSE 1 END
        -- The first item from cascaded CROSS APPLY c below
        ,Item
        -- The remaining elements of the string is created (for this recursion) here
        ,Remaining=CASE
            WHEN DATALENGTH(@String) = DATALENGTH(Item) THEN ''''
            ELSE SUBSTRING(@String, DATALENGTH(Item)+1, DATALENGTH(@String)) END
        -- NotPattern is the converse of Pattern (calculated in CROSS APPLY a below)
        ,NotPattern
        ,[Matched]=CASE WHEN @String IS NULL THEN NULL WHEN a=1 THEN 1 ELSE 0 END
    FROM (
        -- Only create the "NotPattern" once in the anchor leg
        SELECT REPLACE(REPLACE(@Pattern, ''['', ''[^''), ''^^'', '''')) a(NotPattern)
    -- Note that the original version of this FUNCTION included this CROSS APPLY to calculate
    -- a and b in the recursive leg also.  Removing it there and embedding PATINDEX wherever
    -- a and b appear in the final CROSS APPLY improved performance measurably at the expense
    -- of some readability.
    CROSS APPLY (
        -- Find the first occurrence of the Pattern and the NotPattern
        SELECT PATINDEX(@Pattern, @String)
            ,PATINDEX(NotPattern, @String)
        ) b(a, b)
    CROSS APPLY (
        -- Identify the first item (chunk)
        SELECT CASE
            -- When a+b = 1, then either a=1 and b=0 (pattern found but not pattern is not found)
            -- or a=0 and b=1 (not pattern found but pattern is not found). 
            -- In either case we''re done.
            WHEN a+b = 1 THEN @String
            WHEN (a=1 AND b>0) OR (b=1 AND a>0)
                THEN SUBSTRING(@String, 1, CASE a WHEN 1 THEN b ELSE a END-1)
            ELSE @String        -- Return value for unsupported patterns
            END) c(Item)
    UNION ALL
    -- Recursive leg of PatternSplitter rCTE
    SELECT ItemNumber+1
        -- The next item from CROSS APPLY b below
        ,b.Item
        -- The remaining elements of the string is created (for the remainding recursions) here
        ,Remaining=CASE
            WHEN DATALENGTH(Remaining) = DATALENGTH(b.Item) THEN ''''
            ELSE SUBSTRING(Remaining, DATALENGTH(b.Item)+1, DATALENGTH(Remaining)) END
        -- The NotPattern is only calculated once (to avoid added cost of the REPLACE)
        ,NotPattern
        ,CASE PATINDEX(@Pattern, Remaining) WHEN 1 THEN 1 ELSE 0 END
    FROM PatternSplitter
    CROSS APPLY (
        -- Identify the next item (chunk)
        SELECT CASE
            -- For below: a=PATINDEX(@Pattern, Remaining) and b=PATINDEX(NotPattern, Remaining)
            -- When a+b = 1, then either a=1 and b=0 (pattern found but not pattern is not found)
            -- or a=0 and b=1 (not pattern found but pattern is not found). 
            -- In either case we''re done.
            WHEN PATINDEX(@Pattern, Remaining) + PATINDEX(NotPattern, Remaining) = 1
                THEN Remaining
            WHEN (PATINDEX(@Pattern, Remaining)=1 AND PATINDEX(NotPattern, Remaining)>0) OR
                (PATINDEX(NotPattern, Remaining)=1 AND PATINDEX(@Pattern, Remaining)>0)
                THEN SUBSTRING(Remaining, 1,
                    CASE PATINDEX(@Pattern, Remaining)
                        WHEN 1 THEN PATINDEX(NotPattern, Remaining)
                        ELSE PATINDEX(@Pattern, Remaining) END-1)
            ELSE Remaining          -- Should never occur
            END) b(Item)
    -- When Remaining is an empty string, there''s nothing left to process so we''re done.
    WHERE DATALENGTH(Remaining) > 0
    )
SELECT ItemNumber, Item, [Matched]
FROM PatternSplitter' 
END
GO
