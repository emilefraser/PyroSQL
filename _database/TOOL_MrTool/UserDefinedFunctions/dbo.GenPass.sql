SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ============================================================
-- Author:      Eli Leiba
-- Create date: 01-2018
-- Description: a view and a scalar UDF to generate a random
-- 8 characters password
-- ============================================================
CREATE FUNCTION [dbo].[GenPass]()
RETURNS VARCHAR(8)
AS
BEGIN
   -- Declare the variables here
   DECLARE @Result VARCHAR(8)
   DECLARE @BinaryData VARBINARY(8)
   DECLARE @CharacterData VARCHAR(8)
 
   SELECT @BinaryData = randval
   FROM vRandom
 
   Set @CharacterData=cast ('' as xml).value ('xs:base64Binary(sql:variable("@BinaryData"))',
                   'varchar (max)')
   
   SET @Result = @CharacterData
   
   -- Return the result of the function
   RETURN @Result
END

GO
