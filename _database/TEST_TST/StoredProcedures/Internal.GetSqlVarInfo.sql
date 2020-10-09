SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION: GetSqlVarInfo
-- Determines the data type and the data type family for the value 
-- stored in @SqlVariant.
-- Also converts @SqlVariant in a string applying a CONVERT that will 
-- force the maximum precision.
--    The data type           The data type family             Abreviation
--       sql_variant                sql_variant                SV
--       datetime                   Date and Time              DT
--       smalldatetime              Date and Time              DT
--       float                      Approximate numeric        AN
--       real                       Approximate numeric        AN
--       numeric                    Exact numeric              EN
--       decimal                    Exact numeric              EN
--       money                      Exact numeric              EN
--       smallmoney                 Exact numeric              EN
--       bigint                     Exact numeric              EN
--       int                        Exact numeric              EN
--       smallint                   Exact numeric              EN
--       tinyint                    Exact numeric              EN
--       bit                        Exact numeric              EN
--       nvarchar                   Unicode                    UC
--       nchar                      Unicode                    UC
--       varchar                    Unicode                    UC
--       char                       Unicode                    UC
--       varbinary                  Binary                     BI
--       binary                     Binary                     BI
--       uniqueidentifier           Uniqueidentifier           UQ
--       Other                      Other                      ??
--
-- If @SqlVariant is NULL then both @BaseType and @DataTypeFamily will 
-- be returend as NULL.
-- =======================================================================
CREATE PROCEDURE Internal.GetSqlVarInfo
   @SqlVariant       sql_variant,
   @BaseType         sysname OUT,
   @DataTypeFamily   char(2) OUT,
   @StringValue      nvarchar(max) OUT
AS
BEGIN

   SET @BaseType         = NULL
   SET @DataTypeFamily   = NULL
   SET @StringValue      = 'NULL'
   
   IF (@SqlVariant IS NULL) RETURN

   SET @BaseType = CAST(SQL_VARIANT_PROPERTY (@SqlVariant, 'BaseType') AS sysname)
   SET @StringValue = CONVERT(nvarchar(max), @SqlVariant); 
         IF (@BaseType = 'sql_variant'      ) BEGIN SET @DataTypeFamily = 'SV'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'datetime'         ) BEGIN SET @DataTypeFamily = 'DT'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 121 ); END
   ELSE  IF (@BaseType = 'smalldatetime'    ) BEGIN SET @DataTypeFamily = 'DT'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 121 ); END
   ELSE  IF (@BaseType = 'float'            ) BEGIN SET @DataTypeFamily = 'AN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 2   ); END
   ELSE  IF (@BaseType = 'real'             ) BEGIN SET @DataTypeFamily = 'AN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 2   ); END
   ELSE  IF (@BaseType = 'numeric'          ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'decimal'          ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'money'            ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 2   ); END
   ELSE  IF (@BaseType = 'smallmoney'       ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant, 2   ); END
   ELSE  IF (@BaseType = 'bigint'           ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'int'              ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'smallint'         ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'tinyint'          ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'bit'              ) BEGIN SET @DataTypeFamily = 'EN'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'nvarchar'         ) BEGIN SET @DataTypeFamily = 'UC'; SET @StringValue = '''' + CONVERT(nvarchar(max), @SqlVariant) + ''''; END
   ELSE  IF (@BaseType = 'nchar'            ) BEGIN SET @DataTypeFamily = 'UC'; SET @StringValue = '''' + CONVERT(nvarchar(max), @SqlVariant) + ''''; END
   ELSE  IF (@BaseType = 'varchar'          ) BEGIN SET @DataTypeFamily = 'UC'; SET @StringValue = '''' + CONVERT(nvarchar(max), @SqlVariant) + ''''; END
   ELSE  IF (@BaseType = 'char'             ) BEGIN SET @DataTypeFamily = 'UC'; SET @StringValue = '''' + CONVERT(nvarchar(max), @SqlVariant) + ''''; END
   ELSE  IF (@BaseType = 'varbinary'        ) BEGIN SET @DataTypeFamily = 'BI'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'binary'           ) BEGIN SET @DataTypeFamily = 'BI'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END
   ELSE  IF (@BaseType = 'uniqueidentifier' ) BEGIN SET @DataTypeFamily = 'UQ'; SET @StringValue = '{' + CONVERT(nvarchar(max), @SqlVariant) + '}'; END
   ELSE                                       BEGIN SET @DataTypeFamily = '??'; SET @StringValue = CONVERT(nvarchar(max), @SqlVariant      ); END

END

GO
