CREATE PROCEDURE dbo.SelectStarInCteTest
AS 
/* Cant SELECT * coz of DBA 
   why pffts ?? */
WITH ctex
AS (
SELECT * FROM sys.objects
)
SELECT ctex.name,ctex.object_id FROM ctex

go