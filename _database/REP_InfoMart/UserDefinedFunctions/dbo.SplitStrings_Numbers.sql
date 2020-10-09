SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[SplitStrings_Numbers]
(
   @List        NVARCHAR(MAX),
   @Delimiter   NVARCHAR(255),
   @nth			INT
)
RETURNS NVARCHAR(255)
AS
 BEGIN 

   declare @returnvalue NVARCHAR(255)

   SELECT @returnvalue = string from (
       SELECT ROW_NUMBER() OVER (ORDER by n) AS rn,  SUBSTRING(@List, n, 
         CHARINDEX(@Delimiter, @List + @Delimiter, n) - n) AS string
       FROM MsHelper.dbo.Numbers
       WHERE n <= CONVERT(INT, LEN(@List))
         AND SUBSTRING(@Delimiter + @List, n, LEN(@Delimiter)) = @Delimiter
		) AS sq 
		WHERE sq.rn = @nth
		
		
	RETURN @returnvalue


END

GO
