SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.IsNotLike
-- Can be called by the test procedures to verify that 
-- a given character string does NOT match a specified pattern.
-- The @EscapeCharacter will be used as part of the LIKE operator. 
-- The NOT LIKE expression is written as:  
--       @ActualValue NOT LIKE @ExpectedLikeValue ESCAPE @EscapeCharacter
-- @EscapeCharacter can be use if one needs to escape wildcard characters 
-- like %_[]^ from the pattern. See the LIKE operator documentation.
-- Note: NULL is invalid for @ExpectedNotLikeValue. If Assert.IsNotLike is
--       called with NULL for @ExpectedNotLikeValue then it will fail with 
--       an ERROR. Use Assert.IsNotNull instead.
-- Note: If @ActualValue IS NULL then Assert.IsNotLike will fail.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.IsNotLike
   @ContextMessage         nvarchar(1000),
   @ExpectedNotLikeValue   nvarchar(max),
   @ActualValue            nvarchar(max),
   @EscapeCharacter        char = NULL
AS
BEGIN
   DECLARE @Message        nvarchar(4000)
   DECLARE @EscapeMessage  nvarchar(100)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedNotLikeValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.IsNotLike. [' + @ContextMessage + '] @ExpectedNotLikeValue cannot be NULL. Use Assert.IsNotNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue NOT LIKE @ExpectedNotLikeValue ESCAPE @EscapeCharacter)
   BEGIN
      SET @Message = 'Assert.IsNotLike passed. [' + @ContextMessage + '] Test value: ''' + ISNULL(CAST(@ExpectedNotLikeValue as nvarchar(max)), 'NULL') + '''. Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @EscapeMessage = ''
   IF (@EscapeCharacter IS NOT NULL) SET @EscapeMessage = ' Escape: ' + @EscapeCharacter

   SET @Message = 'Assert.IsNotLike failed. [' + @ContextMessage + ']' + @EscapeMessage + ' Test value: ''' + ISNULL(CAST(@ExpectedNotLikeValue as nvarchar(max)), 'NULL') + '''. Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
   EXEC Assert.Fail @Message

END

GO
