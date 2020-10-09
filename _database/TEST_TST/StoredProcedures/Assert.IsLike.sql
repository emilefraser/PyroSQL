SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: Assert.IsLike
-- Can be called by the test procedures to verify that 
-- @ActualValue matches the pattern specified in @ExpectedLikeValue.
-- The @EscapeCharacter will be used as part of the LIKE operator. 
-- The LIKE expression is written as:  
--       @ActualValue LIKE @ExpectedLikeValue ESCAPE @EscapeCharacter
-- @EscapeCharacter can be use if one needs to escape wildcard characters 
-- like %_[]^ from the pattern. See the LIKE operator documentation.
-- Note: NULL is invalid for @ExpectedLikeValue. If Assert.IsLike is
--       called with NULL for @ExpectedLikeValue then it will fail with 
--       an ERROR. Use Assert.IsNull instead.
-- Note: If @ActualValue IS NULL then Assert.IsLike will fail.
-- If passes it will record an entry in TestLog.
-- If failes it will record an entry in TestLog and raise an error.
-- =======================================================================
CREATE PROCEDURE Assert.IsLike
   @ContextMessage      nvarchar(1000),
   @ExpectedLikeValue   nvarchar(max),
   @ActualValue         nvarchar(max),
   @EscapeCharacter     char = NULL
AS
BEGIN

   DECLARE @Message        nvarchar(4000)
   DECLARE @EscapeMessage  nvarchar(100)

   SET @ContextMessage = ISNULL(@ContextMessage, '')

   IF (@ExpectedLikeValue IS NULL )
   BEGIN
      SET @Message = 'Invalid call to Assert.IsLike. [' + @ContextMessage + '] @ExpectedLikeValue cannot be NULL. Use Assert.IsNull instead.'
      EXEC Internal.LogErrorMessageAndRaiseError @Message
      RETURN
   END

   IF (@ActualValue LIKE @ExpectedLikeValue ESCAPE @EscapeCharacter)
   BEGIN
      SET @Message = 'Assert.IsLike passed. [' + @ContextMessage + '] Test value: ''' + ISNULL(CAST(@ExpectedLikeValue as nvarchar(max)), 'NULL') + '''. Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
      EXEC Assert.Pass @Message
      RETURN
   END

   SET @EscapeMessage = ''
   IF (@EscapeCharacter IS NOT NULL) SET @EscapeMessage = ' Escape: ' + @EscapeCharacter
   
   SET @Message = 'Assert.IsLike failed. [' + @ContextMessage + ']' + @EscapeMessage + ' Test value: ''' + ISNULL(CAST(@ExpectedLikeValue as nvarchar(max)), 'NULL') + '''. Actual value: ''' + ISNULL(CAST(@ActualValue as nvarchar(max)), 'NULL') + ''''
   EXEC Assert.Fail @Message

END

GO
