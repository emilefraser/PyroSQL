
CREATE PROCEDURE dbo.ConvertDateMultipeCond
AS

SELECT create_date,CONVERT(varchar(255),create_date,120)
FROM sys.objects
WHERE '22'  =CAST(object_id AS VARCHAR(10))
