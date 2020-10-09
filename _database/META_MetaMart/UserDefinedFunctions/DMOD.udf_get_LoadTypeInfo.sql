SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Francois Senekal
-- Create Date: 2019/06/10
-- Description: Function that displays Load type info
-- =============================================

-- Sample execution
--   select [DMOD].[udf_get_LoadTypeInfo](5, 'Frans Germhuizen')

CREATE FUNCTION [DMOD].[udf_get_LoadTypeInfo]
(
    @LoadConfigID int
    , @Author varchar(50) = 'Default Value: Author not provided'
)
RETURNS varchar(max)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result varchar(MAX)
	DECLARE @NewLineChar as CHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @TabChar as CHAR(1) = CHAR(9)

	SET @Result =
	(
	SELECT	'--!~ LoadTypeInfo'
			+ @NewLineChar
			+'/*'
			+ @NewLineChar +		
			@TabChar + 'Template Version No.:                       |   V '+  CONVERT(varchar,loadt.LoadScriptVersionNo,1) 
			+ @NewLineChar +
			@TabChar + 'Template last update date:                  |   ' +    ISNULL(CONVERT(varchar(100),loadt.ModifiedDT,127), 'Never') 
			+ @NewLineChar +
			@TabChar + 'Template load Type code:                    |   ' +    ISNULL(CONVERT(varchar(100),loadt.LoadTypeCode,1), 'None') 
			+ @NewLineChar +
			@TabChar + 'Template load Type description:             |   ' +    ISNULL(CONVERT(varchar(1000),loadt.LoadTypeDescription,1), 'None') 
			+ @NewLineChar +
			@TabChar + 'Template Author:                            |   ' +    @Author 
			+ @NewLineChar +
			@TabChar + 'Stored Proc Create Date:                    |   ' +    ISNULL(CONVERT(varchar,GETDATE(),126), 'None') 
			+ @NewLineChar +
			+'*/'
			+ @NewLineChar
			+ '-- End of LoadTypeInfo ~!'
	FROM DMOD.LoadType loadt
		INNER JOIN DMOD.LoadConfig loadc ON
			loadt.LoadTypeID = loadc.LoadTypeID  
	WHERE	loadc.LoadConfigID = @LoadConfigID
	)


/* 
	Template Version No.:                       |   V 1.50   
	Template last update date:                  |   NEVER   
	Template load Type code:                    |   StageFullLoad_KEYS   
	Template load Type description:             |   Load a full data set for a StageArea KEYS table   
	Template Author:                            |   Francois Senekal   
	Stored Proc Create Date:                    |   Load a full data set for a Sta  
*/

RETURN @Result
END

GO
