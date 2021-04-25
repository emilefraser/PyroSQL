SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_Internal_GetColumnPart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION : SFN_Internal_GetColumnPart
-- Generates a portion of the SQL query that is used in RunTableComparison. 
-- See RunTableComparison and GenerateComparisonSQLQuery.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_Internal_GetColumnPart](
   @BareColumnName   sysname, 
   @DataTypeName     nvarchar(128), 
   @MaxLength        int, 
   @ColumnPrecision int) RETURNS nvarchar(max)
AS
BEGIN

   DECLARE @ExpectedResultConvertString   nvarchar(max)
   DECLARE @ActualResultConvertString     nvarchar(max)
   DECLARE @ColumnPartString              nvarchar(max)
   DECLARE @ReplacementValue              nvarchar(max)
   DECLARE @EscapedColumnName             sysname

   DECLARE @ConvertType     varchar(20)
   DECLARE @ConvertLength   varchar(20)
   DECLARE @ConvertStyle    varchar(20)
   DECLARE @UseConvert      int           -- 1 Use CONVERT
                                          -- 2 Use the column without aplying CONVERT
                                          -- 3 Use the string contained in @ReplacementValue

   SET @ConvertType     = ''varchar''
   SET @ConvertLength   = ''''           -- We assume we don''t need to specify the lenght in CONVERT
   SET @ConvertStyle    = ''''           -- We asume that we don''t need to specify the style in CONVERT
   SET @UseConvert      = 1            -- We assume that we do need to use CONVERT to nvarchar
   SET @EscapedColumnName = ''['' + @BareColumnName + '']''

   IF      (@DataTypeName = ''money''            )    BEGIN SET @ConvertStyle = '', 2''; END
   ELSE IF (@DataTypeName = ''smallmoney''       )    BEGIN SET @ConvertStyle = '', 2''; END
   ELSE IF (@DataTypeName = ''decimal''          )    BEGIN SET @ConvertLength = ''('' + CAST(@ColumnPrecision + 10 AS varchar) + '')''; END
   ELSE IF (@DataTypeName = ''numeric''          )    BEGIN SET @ConvertLength = ''('' + CAST(@ColumnPrecision + 10 AS varchar) + '')''; END
   ELSE IF (@DataTypeName = ''float''            )    BEGIN SET @ConvertStyle = '', 2''; SET @ConvertLength = ''(30)''; END
   ELSE IF (@DataTypeName = ''real''             )    BEGIN SET @ConvertStyle = '', 1''; SET @ConvertLength = ''(30)''; END
   ELSE IF (@DataTypeName = ''datetime''         )    BEGIN SET @ConvertStyle = '', 121''; END
   ELSE IF (@DataTypeName = ''smalldatetime''    )    BEGIN SET @ConvertStyle = '', 120''; END
   ELSE IF (@DataTypeName = ''char''             )    BEGIN SET @ConvertLength = ''('' + CAST(@MaxLength AS varchar) + '')''; END
   ELSE IF (@DataTypeName = ''nchar''            )    BEGIN SET @ConvertLength = ''('' + CAST(@MaxLength/2 AS varchar) + '')''; SET @ConvertType = ''nvarchar''; END
   ELSE IF (@DataTypeName = ''varchar''          )    
   BEGIN 
      IF (@MaxLength = -1) SET @ConvertLength = ''(max)''
      ELSE                 SET @ConvertLength = ''('' + CAST(@MaxLength AS varchar) + '')''
   END
   ELSE IF (@DataTypeName = ''nvarchar''         )    
   BEGIN 
      SET @ConvertType = ''nvarchar''
      IF (@MaxLength = -1) SET @ConvertLength = ''(max)''
      ELSE                 SET @ConvertLength = ''('' + CAST(@MaxLength/2 AS varchar) + '')''
   END
   ELSE IF (@DataTypeName = ''binary''           )    BEGIN SET @ReplacementValue = ''...binary value...''; SET @UseConvert = 3; END
   ELSE IF (@DataTypeName = ''varbinary''        )    BEGIN SET @ReplacementValue = ''...binary value...''; SET @UseConvert = 3; END
   ELSE IF (@DataTypeName = ''uniqueidentifier'' )    BEGIN SET @ConvertLength = ''(36)''; END



   IF (@UseConvert = 1)
   BEGIN
      SET @ExpectedResultConvertString = ''CONVERT('' + @ConvertType + @ConvertLength + '', #ExpectedResult.'' + @EscapedColumnName + @ConvertStyle + '') COLLATE database_default ''
      SET @ActualResultConvertString   = ''CONVERT('' + @ConvertType + @ConvertLength + '', #ActualResult.''   + @EscapedColumnName + @ConvertStyle + '') COLLATE database_default ''
   END
   ELSE IF (@UseConvert = 2)
   BEGIN
      SET @ExpectedResultConvertString = ''#ExpectedResult.'' + @EscapedColumnName
      SET @ActualResultConvertString   = ''#ActualResult.'' + @EscapedColumnName
   END

   IF (@UseConvert = 3)
   BEGIN
      SET @ColumnPartString = '''''''' + @BareColumnName + ''=('' + @ReplacementValue + ''/'' + @ReplacementValue + '') '''' ''
   END
   ELSE
   BEGIN
      SET @ColumnPartString = '''''''' + @BareColumnName + 
               ''=('''' + ISNULL(''     + @ExpectedResultConvertString + '', ''''null'''')'' + 
               '' + ''''/'''' + ISNULL('' + @ActualResultConvertString   + '', ''''null'''') + '''') '''' ''
   END
   
   RETURN @ColumnPartString

END
' 
END
GO
