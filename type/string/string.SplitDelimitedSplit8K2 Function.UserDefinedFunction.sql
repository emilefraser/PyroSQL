DROP FUNCTION [dbo].[DelimitedSplit8K]
go
 CREATE FUNCTION [dbo].[DelimitedSplit8K]
/**********************************************************************************************************************
 Purpose:
 Split a given string at a given delimiter and return a list of the split elements (items).

 Notes:
 1.  Leading a trailing delimiters are treated as if an empty string element were present.
 2.  Consecutive delimiters are treated as if an empty string element were present between them.
 3.  Except when spaces are used as a delimiter, all spaces present in each element are preserved.

 Returns:
 iTVF containing the following:
 ItemNumber = Element position of Item as a BIGINT (not converted to INT to eliminate a CAST)
 Item       = Element value as a VARCHAR(8000)

 Statistics on this function may be found at the following URL:
 http://www.sqlservercentral.com/Forums/Topic1101315-203-4.aspx

 CROSS APPLY Usage Examples and Tests:
--=====================================================================================================================
-- TEST 1:
-- This tests for various possible conditions in a string using a comma as the delimiter.  The expected results are
-- laid out in the comments
--=====================================================================================================================
--===== Conditionally drop the test tables to make reruns easier for testing.
     -- (this is NOT a part of the solution)
     IF OBJECT_ID('tempdb..#JBMTest') IS NOT NULL DROP TABLE #JBMTest
;
--===== Create and populate a test table on the fly (this is NOT a part of the solution).
     -- In the following comments, "b" is a blank and "E" is an element in the left to right order.
     -- Double Quotes are used to encapsulate the output of "Item" so that you can see that all blanks
     -- are preserved no matter where they may appear.
 SELECT *
   INTO #JBMTest
   FROM (                                               --# & type of Return Row(s)
         SELECT  0, NULL                      UNION ALL --1 NULL
         SELECT  1, SPACE(0)                  UNION ALL --1 b (Empty String)
         SELECT  2, SPACE(1)                  UNION ALL --1 b (1 space)
         SELECT  3, SPACE(5)                  UNION ALL --1 b (5 spaces)
         SELECT  4, ','                       UNION ALL --2 b b (both are empty strings)
         SELECT  5, '55555'                   UNION ALL --1 E
         SELECT  6, ',55555'                  UNION ALL --2 b E
         SELECT  7, ',55555,'                 UNION ALL --3 b E b
         SELECT  8, '55555,'                  UNION ALL --2 b B
         SELECT  9, '55555,1'                 UNION ALL --2 E E
         SELECT 10, '1,55555'                 UNION ALL --2 E E
         SELECT 11, '55555,4444,333,22,1'     UNION ALL --5 E E E E E 
         SELECT 12, '55555,4444,,333,22,1'    UNION ALL --6 E E b E E E
         SELECT 13, ',55555,4444,,333,22,1,'  UNION ALL --8 b E E b E E E b
         SELECT 14, ',55555,4444,,,333,22,1,' UNION ALL --9 b E E b b E E E b
         SELECT 15, ' 4444,55555 '            UNION ALL --2 E (w/Leading Space) E (w/Trailing Space)
         SELECT 16, 'This,is,a,test.'                   --E E E E
        ) d (SomeID, SomeValue)
;
--===== Split the CSV column for the whole table using CROSS APPLY (this is the solution)
 SELECT test.SomeID, test.SomeValue, split.ItemNumber, Item = QUOTENAME(split.Item,'"')
   FROM #JBMTest test
  CROSS APPLY dbo.DelimitedSplit8K(test.SomeValue,',') split
;
--=====================================================================================================================
-- TEST 2:
-- This tests for various "alpha" splits and COLLATION using all ASCII characters from 0 to 255 as a delimiter against
-- a given string.  Note that not all of the delimiters will be visible and some will show up as tiny squares because
-- they are "control" characters.  More specifically, this test will show you what happens to various non-accented 
-- letters for your given collation depending on the delimiter you chose.
--=====================================================================================================================
WITH 
cteBuildAllCharacters (String,Delimiter) AS 
(
 SELECT TOP 256 
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
        CHAR(ROW_NUMBER() OVER (ORDER BY (SELECT NULL))-1)
   FROM master.sys.all_columns
)
 SELECT ASCII_Value = ASCII(c.Delimiter), c.Delimiter, split.ItemNumber, Item = QUOTENAME(split.Item,'"')
   FROM cteBuildAllCharacters c
  CROSS APPLY dbo.DelimitedSplit8K(c.String,c.Delimiter) split
  ORDER BY ASCII_Value, split.ItemNumber
;
-----------------------------------------------------------------------------------------------------------------------
 Other Notes:
 1. Optimized for VARCHAR(8000) or less.  No testing or error reporting for truncation at 8000 characters is done.
 2. Optimized for single character delimiter.  Multi-character delimiters should be resolvedexternally from this 
    function.
 3. Optimized for use with CROSS APPLY.
 4. Does not "trim" elements just in case leading or trailing blanks are intended.
 5. If you don't know how a Tally table can be used to replace loops, please see the following...
    http://www.sqlservercentral.com/articles/T-SQL/62867/
 6. Changing this function to use NVARCHAR(MAX) will cause it to run twice as slow.  It's just the nature of 
    VARCHAR(MAX) whether it fits in-row or not.
 7. Multi-machine testing for the method of using UNPIVOT instead of 10 SELECT/UNION ALLs shows that the UNPIVOT method
    is quite machine dependent and can slow things down quite a bit.
-----------------------------------------------------------------------------------------------------------------------
 Credits:
 This code is the product of many people's efforts including but not limited to the following:
 cteTally concept originally by Iztek Ben Gan and "decimalized" by Lynn Pettis (and others) for a bit of extra speed
 and finally redacted by Jeff Moden for a different slant on readability and compactness. Hat's off to Paul White for
 his simple explanations of CROSS APPLY and for his detailed testing efforts. Last but not least, thanks to
 Ron "BitBucket" McCullough and Wayne Sheffield for their extreme performance testing across multiple machines and
 versions of SQL Server.  The latest improvement brought an additional 15-20% improvement over Rev 05.  Special thanks
 to "Nadrek" and "peter-757102" (aka Peter de Heer) for bringing such improvements to light.  Nadrek's original
 improvement brought about a 10% performance gain and Peter followed that up with the content of Rev 07.  

 I also thank whoever wrote the first article I ever saw on "numbers tables" which is located at the following URL
 and to Adam Machanic for leading me to it many years ago.
 http://sqlserver2000.databases.aspfaq.com/why-should-i-consider-using-an-auxiliary-numbers-table.html
-----------------------------------------------------------------------------------------------------------------------
 Revision History:
 Rev 00 - 20 Jan 2010 - Concept for inline cteTally: Lynn Pettis and others.
                        Redaction/Implementation: Jeff Moden 
        - Base 10 redaction and reduction for CTE.  (Total rewrite)

 Rev 01 - 13 Mar 2010 - Jeff Moden
        - Removed one additional concatenation and one subtraction from the SUBSTRING in the SELECT List for that tiny
          bit of extra speed.

 Rev 02 - 14 Apr 2010 - Jeff Moden
        - No code changes.  Added CROSS APPLY usage example to the header, some additional credits, and extra 
          documentation.

 Rev 03 - 18 Apr 2010 - Jeff Moden
        - No code changes.  Added notes 7, 8, and 9 about certain "optimizations" that don't actually work for this
          type of function.

 Rev 04 - 29 Jun 2010 - Jeff Moden
        - Added WITH SCHEMABINDING thanks to a note by Paul White.  This prevents an unnecessary "Table Spool" when the
          function is used in an UPDATE statement even though the function makes no external references.

 Rev 05 - 02 Apr 2011 - Jeff Moden
        - Rewritten for extreme performance improvement especially for larger strings approaching the 8K boundary and
          for strings that have wider elements.  The redaction of this code involved removing ALL concatenation of 
          delimiters, optimization of the maximum "N" value by using TOP instead of including it in the WHERE clause,
          and the reduction of all previous calculations (thanks to the switch to a "zero based" cteTally) to just one 
          instance of one add and one instance of a subtract. The length calculation for the final element (not 
          followed by a delimiter) in the string to be split has been greatly simplified by using the ISNULL/NULLIF 
          combination to determine when the CHARINDEX returned a 0 which indicates there are no more delimiters to be
          had or to start with. Depending on the width of the elements, this code is between 4 and 8 times faster on a
          single CPU box than the original code especially near the 8K boundary.
        - Modified comments to include more sanity checks on the usage example, etc.
        - Removed "other" notes 8 and 9 as they were no longer applicable.

 Rev 06 - 12 Apr 2011 - Jeff Moden
        - Based on a suggestion by Ron "Bitbucket" McCullough, additional test rows were added to the sample code and
          the code was changed to encapsulate the output in pipes so that spaces and empty strings could be perceived 
          in the output.  The first "Notes" section was added.  Finally, an extra test was added to the comments above.

 Rev 07 - 06 May 2011 - Peter de Heer, a further 15-20% performance enhancement has been discovered and incorporated 
          into this code which also eliminated the need for a "zero" position in the cteTally table. 
**********************************************************************************************************************/
--===== Define I/O parameters
        (@pString VARCHAR(8000), @pDelimiter CHAR(1))
RETURNS TABLE WITH SCHEMABINDING AS
 RETURN
--===== "Inline" CTE Driven "Tally Table" produces values from 0 up to 10,000...
     -- enough to cover NVARCHAR(4000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@pString),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                ),
cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                 SELECT 1 UNION ALL
                 SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@pString,t.N,1) = @pDelimiter
                ),
cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                 SELECT s.N1,
                        ISNULL(NULLIF(CHARINDEX(@pDelimiter,@pString,s.N1),0)-s.N1,8000)
                   FROM cteStart s
                )
--===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
 SELECT ItemNumber = ROW_NUMBER() OVER(ORDER BY l.N1),
        Item       = SUBSTRING(@pString, l.N1, l.L1)
   FROM cteLen l
;
GO