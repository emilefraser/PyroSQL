SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[generate].[GetSSNs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [generate].[GetSSNs] AS' 
END
GO
ALTER     PROCEDURE [generate].[GetSSNs]
	@Count AS BIGINT,
	@FormatChar VARCHAR(1) = ''
AS
/******************************************************************************
* Name     : generate.GetSSNs
* Purpose  : Generates a table of random social security number data.
* Inputs   : @Count - number of social security numbers to generate.
* Outputs  : none
* Returns  : (See RESULT SETS definition)
******************************************************************************
* Change History
*	03/17/2020	DMason	Created.
******************************************************************************/
BEGIN

IF @Count <= 0
BEGIN
	SELECT CAST(NULL AS VARCHAR(16))
	WHERE 1 = 2;

	RETURN;
END

DECLARE @RScript NVARCHAR(MAX) = N'  
library(generate)
total_people <- ' + CAST(@Count AS NVARCHAR(MAX)) + '

#SSNs.
SSN <- generate::r_national_identification_numbers(total_people)
SSN <- gsub("-", "' + RTRIM(@FormatChar) + '", SSN)
People <- as.data.frame(SSN)
';

EXEC sp_execute_external_script  
	@language = N'R',
	@script = @RScript,
	@output_data_1_name = N'People'
WITH RESULT SETS 
(
	(
		SSN VARCHAR(16)
	)
);
END
GO
