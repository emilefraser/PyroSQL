SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[GenerateInsertScripts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[GenerateInsertScripts] AS' 
END
GO
--------Final Procedure To generate Script------

ALTER PROCEDURE [meta].[GenerateInsertScripts]
(
    @TABLE_NAME VARCHAR(MAX),
    @FILTER_CONDITION VARCHAR(MAX)=''
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @CSV_COLUMN VARCHAR(MAX),
        @QUOTED_DATA VARCHAR(MAX),
        @TEXT VARCHAR(MAX)

SELECT @CSV_COLUMN=STUFF
(
    (
     SELECT ',['+ NAME +']' FROM sys.all_columns 
     WHERE OBJECT_ID=OBJECT_ID(@TABLE_NAME) AND 
     is_identity!=1 FOR XML PATH('')
    ),1,1,''
)

SELECT @QUOTED_DATA=STUFF
(
    (
     SELECT ' ISNULL(QUOTENAME('+NAME+','+QUOTENAME('''','''''')+'),'+'''NULL'''+')+'','''+'+' FROM sys.all_columns 
     WHERE OBJECT_ID=OBJECT_ID(@TABLE_NAME) AND 
     is_identity!=1 FOR XML PATH('')
    ),1,1,''
)

SELECT @TEXT='SELECT ''INSERT INTO '+@TABLE_NAME+'('+@CSV_COLUMN+')VALUES('''+'+'+SUBSTRING(@QUOTED_DATA,1,LEN(@QUOTED_DATA)-5)+'+'+''')'''+' Insert_Scripts FROM '+@TABLE_NAME + @FILTER_CONDITION

--SELECT @CSV_COLUMN AS CSV_COLUMN,@QUOTED_DATA AS QUOTED_DATA,@TEXT TEXT

EXECUTE (@TEXT)

SET NOCOUNT OFF

END
GO
