use master
GO
IF OBJECT_ID('[dbo].[sp_help_foreignkeys]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_foreignkeys] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_foreignkeys](@TableName sysname=NULL)
AS
SELECT
  DISTINCT
  --FK must be added AFTER the PK/unique constraints are added back.
  850 AS ExecutionOrder,
    QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.parent_object_id)) CurrentObject,
  SCHEMA_NAME(conz.schema_id) As SchemaName,
  OBJECT_NAME(conz.parent_object_id) As TableName,
  ChildCollection.ChildColumns  As CurrentColumns,
  conz.name,
  QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.referenced_object_id)) As ReferencedObject,
  ParentCollection.ParentColumns  As ReferencedColumns,
  'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.parent_object_id)) + ' ADD ' + 
  'CONSTRAINT ' 
  + QUOTENAME(conz.name) 
  + ' FOREIGN KEY (' 
  + ChildCollection.ChildColumns 
  + ') REFERENCES ' 
  + QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.referenced_object_id)) 
  + ' (' + ParentCollection.ParentColumns 
  + ') ' 

  +  CASE conz.update_referential_action
                                        WHEN 0 THEN '' --' ON UPDATE NO ACTION '
                                        WHEN 1 THEN ' ON UPDATE CASCADE '
                                        WHEN 2 THEN ' ON UPDATE SET NULL '
                                        ELSE ' ON UPDATE SET DEFAULT '
                                    END
                  + CASE conz.delete_referential_action
                                        WHEN 0 THEN '' --' ON DELETE NO ACTION '
                                        WHEN 1 THEN ' ON DELETE CASCADE '
                                        WHEN 2 THEN ' ON DELETE SET NULL '
                                        ELSE ' ON DELETE SET DEFAULT '
                                    END
                  + CASE conz.is_not_for_replication
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
  + ',' AS Command
FROM   sys.foreign_keys conz
       INNER JOIN sys.foreign_key_columns colz
         ON conz.object_id = colz.constraint_object_id
      
       INNER JOIN (--gets my child tables column names   
SELECT
 conz.name,
 ChildColumns = STUFF((SELECT 
                         ',' + REFZ.name
                       FROM   sys.foreign_key_columns fkcolz
                              INNER JOIN sys.columns REFZ
                                ON fkcolz.parent_object_id = REFZ.object_id
                                   AND fkcolz.parent_column_id = REFZ.column_id
                       WHERE fkcolz.parent_object_id = conz.parent_object_id
                           AND fkcolz.constraint_object_id = conz.object_id
                         ORDER  BY
                        fkcolz.constraint_column_id
                      FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
FROM   sys.foreign_keys conz
      INNER JOIN sys.foreign_key_columns colz
        ON conz.object_id = colz.constraint_object_id
      WHERE (conz.parent_object_id= object_id(@TableName) OR @TableName IS NULL)
GROUP  BY
conz.name,
conz.parent_object_id,--- without GROUP BY multiple rows are returned
 conz.object_id
    ) ChildCollection
         ON conz.name = ChildCollection.name
       INNER JOIN (--gets the parent tables column names for the FK reference
                  SELECT
                     conz.name,
                     ParentColumns = STUFF((SELECT
                                              ',' + REFZ.name
                                            FROM   sys.foreign_key_columns fkcolz
                                                   INNER JOIN sys.columns REFZ
                                                     ON fkcolz.referenced_object_id = REFZ.object_id
                                                        AND fkcolz.referenced_column_id = REFZ.column_id
                                            WHERE  fkcolz.referenced_object_id = conz.referenced_object_id
                                              AND fkcolz.constraint_object_id = conz.object_id
                                            ORDER BY fkcolz.constraint_column_id
                                            FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
                   FROM   sys.foreign_keys conz
                          INNER JOIN sys.foreign_key_columns colz
                            ON conz.object_id = colz.constraint_object_id
                           -- AND colz.parent_column_id 
                   GROUP  BY
                    conz.name,
                    conz.referenced_object_id,--- without GROUP BY multiple rows are returned
                    conz.object_id
                  ) ParentCollection
         ON conz.name = ParentCollection.name

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_foreignkeys]'
--#################################################################################################
