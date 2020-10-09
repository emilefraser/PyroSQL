SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_EscapeForXml
-- Returns the given string after escaping characters that have a special 
-- role in an XML file.
-- =======================================================================
CREATE FUNCTION Internal.SFN_EscapeForXml(@TextString nvarchar(max)) RETURNS nvarchar(max)
AS
BEGIN

   SET @TextString = REPLACE (@TextString, '"', '&quot;')
   SET @TextString = REPLACE (@TextString, '&', '&amp;')
   SET @TextString = REPLACE (@TextString, '>', '&gt;')
   SET @TextString = REPLACE (@TextString, '<', '&lt;')

   RETURN @TextString 
   
END

GO
