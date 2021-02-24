
CREATE PROCEDURE dbo.SelectStarOutOfCteTest
AS 
/* Cant SELECT * coz of DBA
   Why ?? pfft */
WITH ctex
AS (
SELECT * FROM sys.objects
)
SELECT * FROM ctex

go