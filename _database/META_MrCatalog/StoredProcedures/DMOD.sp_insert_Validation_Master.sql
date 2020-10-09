SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE   PROCEDURE [DMOD].[sp_insert_Validation_Master]
AS
INSERT INTO DMOD.Validation_Master(
       [ValidationName]
      ,[ValidationDescription]
      ,[Database_Validated]
      ,[Valiation_Category]
      ,[ValiationObject_Type]
      ,[DatabaseName]
      ,[SchemaName]
      ,[ObjectName]
)
SELECT 
    o.name
,   o.name
,   'DataManager'
,   'DMOD'
,   o.type_desc
,   'DataManager'
,   s.name AS SchemaName
,   o.name AS ObjectName
FROM
    DataManager.sys.objects AS o
INNER JOIN 
    DataManager.sys.schemas AS s
    ON s.schema_id = o.schema_id
WHERE 
    o.name LIKE '%Validate%'

GO
