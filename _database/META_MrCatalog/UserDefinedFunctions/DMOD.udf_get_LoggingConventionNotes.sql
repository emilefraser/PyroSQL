SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Francois Senekal
-- Create Date: 2019/06/10
-- Description: Function that generates logging convention notes for stored procedure load templates
-- =============================================

--Example execution
--	select [DMOD].[udf_get_LoggingConventionNotes]('SP01')

CREATE FUNCTION [DMOD].[udf_get_LoggingConventionNotes]
(
    @DocumentStandardsCode varchar(100)
)
RETURNS varchar(max)
AS
BEGIN
    
	DECLARE @Result varchar(MAX)
	DECLARE @NewLineChar as CHAR(2) = CHAR(13)
	DECLARE @List varchar(MAX) = ''
	
	SELECT  @List = @List +
			+ CHAR(9) 
			+ CONVERT(varchar,sd.StandardsLineNo,1) 
			+ '.' 
			+ CHAR(9) 
			--@NewLineChar+
			+ sd.StandardsLineDescription 
			+ @NewLineChar
	FROM DOCUMENTATION.Standards_Header sh
		INNER JOIN DOCUMENTATION.Standards_Detail sd ON
			sd.StandardsID	= sh.StandardsID
	WHERE sh.StandardsCode = @DocumentStandardsCode  --(SP01: StandardStageLoadStoredProcLoggingconventionNotes) 

	SET @List =	'--!~ Logging Convention Notes' 
				+ @NewLineChar 
				+ '/*'
				+ @NewLineChar 
				+ LTRIM(RTRIM(@List)) 
				+ @NewLineChar 
				+ '*/'
				+ @NewLineChar
				+ '-- End of Logging Convention Notes ~!'

	RETURN	@List

END

GO
