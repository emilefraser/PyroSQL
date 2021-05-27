SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformToUpperCase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE  FUNCTION [string].[TransformToUpperCase]
(
@string VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
 
DECLARE @Next INT
WHILE 1=1
       BEGIN
       --find word space followed by lower case letter
       --This makes assumptions about the language
       SELECT @next=
           PATINDEX(''%[^a-zA-Z][abcdefghijklmnopqurstuvwzyz]%'',
                       '' ''+@string  collate Latin1_General_CS_AI)
       IF @next =0 BREAK
       SELECT @String =
           STUFF(@String,@Next,1,UPPER(SUBSTRING(@String,@Next,1)))
       END
RETURN @string
END' 
END
GO
