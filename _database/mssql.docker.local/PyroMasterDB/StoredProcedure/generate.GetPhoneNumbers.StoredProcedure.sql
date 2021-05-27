SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[generate].[GetPhoneNumbers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [generate].[GetPhoneNumbers] AS' 
END
GO
ALTER     PROCEDURE [generate].[GetPhoneNumbers]
	@Count BIGINT
AS
/******************************************************************************
* Name     : generate.GetPhoneNumbers
* Purpose  : Generates a table of random phone number data.
* Inputs   : @Count - number of phone numbers to generate.
* Outputs  : none
* Returns  : (See RESULT SETS definition)
******************************************************************************
* Change History
*	03/17/2020	DMason	Created.
******************************************************************************/
BEGIN

IF @Count <= 0
BEGIN
	SELECT CAST(NULL AS NVARCHAR(32))
	WHERE 1 = 2;

	RETURN;
END

DECLARE @RScript NVARCHAR(MAX) = N'  
library(generate)
total_people <- ' + CAST(@Count AS NVARCHAR(MAX)) + '

#Phone numbers. Use the logical/boolean arguments to include hyphens, parentheses, and spaces.
#The resulting formatting is a little strange, so use gsub() to replace unwanted characters.
People <- as.data.frame(
  gsub("- ", "-", gsub(")-", ")", generate::r_phone_numbers(total_people, TRUE, TRUE, TRUE)))
)
names(People) <- c("PhoneNumber")
';

EXEC sp_execute_external_script  
	@language = N'R',
	@script = @RScript,
	@output_data_1_name = N'People'
WITH RESULT SETS 
(
	(
		PhoneNumber NVARCHAR(32)
	)
);
END
GO
