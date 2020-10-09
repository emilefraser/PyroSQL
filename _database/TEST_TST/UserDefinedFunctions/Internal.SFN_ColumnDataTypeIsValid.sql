SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION : SFN_ColumnDataTypeIsValid
-- Returns 1 if the data type given by @DataTypeName can be 
--           processed by Assert.TableEquals
-- Returns 1 if the data type given by @DataTypeName cannot be 
--           processed by Assert.TableEquals
-- =======================================================================
CREATE FUNCTION Internal.SFN_ColumnDataTypeIsValid(@DataTypeName nvarchar(128)) RETURNS bit
AS
BEGIN

   IF (@DataTypeName = 'bigint'           ) RETURN 1
   IF (@DataTypeName = 'int'              ) RETURN 1
   IF (@DataTypeName = 'smallint'         ) RETURN 1
   IF (@DataTypeName = 'tinyint'          ) RETURN 1
   IF (@DataTypeName = 'money'            ) RETURN 1
   IF (@DataTypeName = 'smallmoney'       ) RETURN 1
   IF (@DataTypeName = 'bit'              ) RETURN 1
   IF (@DataTypeName = 'decimal'          ) RETURN 1
   IF (@DataTypeName = 'numeric'          ) RETURN 1
   IF (@DataTypeName = 'float'            ) RETURN 1
   IF (@DataTypeName = 'real'             ) RETURN 1
   IF (@DataTypeName = 'datetime'         ) RETURN 1
   IF (@DataTypeName = 'smalldatetime'    ) RETURN 1
   IF (@DataTypeName = 'char'             ) RETURN 1
   IF (@DataTypeName = 'text'             ) RETURN 0
   IF (@DataTypeName = 'varchar'          ) RETURN 1
   IF (@DataTypeName = 'nchar'            ) RETURN 1
   IF (@DataTypeName = 'ntext'            ) RETURN 0
   IF (@DataTypeName = 'nvarchar'         ) RETURN 1
   IF (@DataTypeName = 'binary'           ) RETURN 1
   IF (@DataTypeName = 'varbinary'        ) RETURN 1
   IF (@DataTypeName = 'image'            ) RETURN 0
   IF (@DataTypeName = 'cursor'           ) RETURN 0
   IF (@DataTypeName = 'timestamp'        ) RETURN 0
   IF (@DataTypeName = 'sql_variant'      ) RETURN 1
   IF (@DataTypeName = 'uniqueidentifier' ) RETURN 1
   IF (@DataTypeName = 'table'            ) RETURN 0
   IF (@DataTypeName = 'xml'              ) RETURN 0

   -- User defined types not accepted
   RETURN 0

END

GO
