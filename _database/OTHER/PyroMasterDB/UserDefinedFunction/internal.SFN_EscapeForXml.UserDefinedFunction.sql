SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_EscapeForXml]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION SFN_EscapeForXml
-- Returns the given string after escaping characters that have a special 
-- role in an XML file.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_EscapeForXml](@TextString nvarchar(max)) RETURNS nvarchar(max)
AS
BEGIN

   SET @TextString = REPLACE (@TextString, ''"'', ''&quot;'')
   SET @TextString = REPLACE (@TextString, ''&'', ''&amp;'')
   SET @TextString = REPLACE (@TextString, ''>'', ''&gt;'')
   SET @TextString = REPLACE (@TextString, ''<'', ''&lt;'')

   RETURN @TextString 
   
END
' 
END
GO
