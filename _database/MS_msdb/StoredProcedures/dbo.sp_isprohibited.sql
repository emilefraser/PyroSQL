SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sp_isprohibited : To test if the attachment is prohibited or not.
--
CREATE PROCEDURE sp_isprohibited
   @attachment nvarchar(max),
   @prohibitedextensions nvarchar(1000)
AS

DECLARE @extensionIndex int
DECLARE @extensionName nvarchar(255)

IF (@attachment IS NOT NULL AND LEN(@attachment) > 0) 
BEGIN
    SET @prohibitedextensions = UPPER(@prohibitedextensions)

   -- find @extensionName: the substring between the last '.' and the end of the string
   SET @extensionIndex = 0
   WHILE (1=1)
   BEGIN
      DECLARE @lastExtensionIndex int
      SET @lastExtensionIndex = CHARINDEX('.', @attachment, @extensionIndex+1)
      IF (@lastExtensionIndex = 0)
         BREAK
      SET @extensionIndex = @lastExtensionIndex
   END

   IF (@extensionIndex > 0)
   BEGIN
      SET @extensionName = SUBSTRING(@attachment, @extensionIndex + 1, (LEN(@attachment) - @extensionIndex)) 
      SET @extensionName = UPPER(@extensionName)

      -- compare @extensionName with each extension in the comma-separated @prohibitedextensions list
      DECLARE @currentExtensionStart int
      DECLARE @currentExtensionEnd int

      SET @currentExtensionStart = 0
      SET @currentExtensionEnd = 0
      WHILE (@currentExtensionEnd < LEN(@prohibitedextensions))
      BEGIN
         SET @currentExtensionEnd = CHARINDEX(',', @prohibitedextensions, @currentExtensionStart)

         IF (@currentExtensionEnd = 0) -- we have reached the last extension of the list, or the list was empty
            SET @currentExtensionEnd = LEN(@prohibitedextensions)+1

         DECLARE @prohibitedExtension nvarchar(1000)
         SET @prohibitedExtension = SUBSTRING(@prohibitedextensions, @currentExtensionStart, @currentExtensionEnd - @currentExtensionStart) 
         SET @prohibitedExtension = RTRIM(LTRIM(@prohibitedExtension))

         IF( @extensionName = @prohibitedExtension )
            RETURN 1

         SET @currentExtensionStart = @currentExtensionEnd + 1
      END
   END

   RETURN 0
END

GO
