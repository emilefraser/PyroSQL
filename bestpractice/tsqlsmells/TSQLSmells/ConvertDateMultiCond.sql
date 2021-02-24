
CREATE PROCEDURE dbo.ConvertDateMultipeCond
AS

SELECT create_date,CONVERT(varchar(255),create_date,120)
FROM sys.objects
WHERE CONVERT(varchar(255),create_date,120)='2009-04-13 12:59:05'
AND CONVERT(varchar(255),create_date,120)='2009-04-13 12:59:05'
