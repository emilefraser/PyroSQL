SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Francois Senekal
-- Create Date: 2019/06/10
-- Description: Function that displays Load type info
-- =============================================
CREATE FUNCTION [DMOD].[udf_StaticTemplate_LoadTypeInfo]
(
    -- Add the parameters for the function here
    @LoadTypeInfo int,
	@Author varchar(50) = 'Francois Senekal'
)
RETURNS varchar(max)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result varchar(MAX)
	DECLARE @NewLineChar as CHAR(2) = CHAR(13) + CHAR(10)

	SET @Result =
	(
	SELECT  '/*'
		   + @NewLineChar +		
		   ' Template Version No.:                       |   V '+  CONVERT(varchar,loadt.LoadScriptVersionNo,1) 
		   + @NewLineChar +
	       ' Template last update date:                  |   ' +    ISNULL(CONVERT(varchar(100),loadc.ModifiedDT,127), 'Never') 
		   + @NewLineChar +
		   ' Template load Type code:                    |   ' +    ISNULL(CONVERT(varchar(100),loadt.LoadTypeCode,1), 'None') 
		   + @NewLineChar +
		   ' Template load Type description:             |   ' +    ISNULL(CONVERT(varchar(1000),loadt.LoadTypeDescription,1), 'None') 
		   + @NewLineChar +
		   ' Template Author:                            |   ' +    @Author 
		   + @NewLineChar +
		   ' Stored Proc Create Date:                    |   ' +    ISNULL(CONVERT(varchar,GETDATE(),1), 'None') 
		   + @NewLineChar +

		   +'*/'
	FROM DMOD.LoadType loadt
		INNER JOIN DMOD.LoadConfig loadc ON
			loadt.LoadTypeID	= loadc.LoadTypeID  
	)

/* Template Version No.:                       |   V 1.50   
   Template last update date:                  |   NEVER   
   Template load Type code:                    |   StageFullLoad_KEYS   
   Template load Type description:             |   Load a full data set for a StageArea KEYS table   
   Template Author:                            |   Francois Senekal   
   Stored Proc Create Date:                    |   Load a full data set for a Sta  
   */


	
    -- Add the T-SQL statements to compute the return value here

RETURN @Result
END

GO
