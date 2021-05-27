SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Generator].[GetFullNames]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Generator].[GetFullNames] AS' 
END
GO
ALTER   PROCEDURE [Generator].[GetFullNames]
	@Count AS BIGINT
AS
/******************************************************************************
* Name     : Generator.GetFullNames
* Purpose  : Generates a table of random full names data.
* Inputs   : @Count - number of names to generate.
* Outputs  : none
* Returns  : (See RESULT SETS definition)
******************************************************************************
* Change History
*	06/24/2020	DMason	Created.
******************************************************************************/
BEGIN

IF @Count <= 0
BEGIN
	SELECT CAST(NULL AS NVARCHAR(255))
	WHERE 1 = 2;

	RETURN;
END

DECLARE @RScript NVARCHAR(MAX) = N'  
library(generator)
total_people <- ' + CAST(@Count AS NVARCHAR(MAX)) + '

#Email addresses.
People <- as.data.frame(generator::r_full_names(total_people))
names(People) <- c("FullName")
';

EXEC sp_execute_external_script  
	@language = N'R',
	@script = @RScript,
	@output_data_1_name = N'People'
WITH RESULT SETS 
(
	(
		FullName NVARCHAR(255)
	)
);
END

GO
