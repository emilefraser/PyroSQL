SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[generate].[GetEmailAddresses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [generate].[GetEmailAddresses] AS' 
END
GO
ALTER     PROCEDURE [generate].[GetEmailAddresses]
	@Count AS BIGINT
AS
/******************************************************************************
* Name     : generate.GetEmailAddresses
* Purpose  : Generates a table of random email address data.
* Inputs   : @Count - number of email addresses to generate.
* Outputs  : none
* Returns  : (See RESULT SETS definition)
******************************************************************************
* Change History
*	03/17/2020	DMason	Created.
******************************************************************************/
BEGIN

IF @Count <= 0
BEGIN
	SELECT CAST(NULL AS NVARCHAR(255))
	WHERE 1 = 2;

	RETURN;
END

DECLARE @RScript NVARCHAR(MAX) = N'  
library(generate)
total_people <- ' + CAST(@Count AS NVARCHAR(MAX)) + '

#Email addresses.
People <- as.data.frame(generate::r_email_addresses(total_people))
names(People) <- c("EmailAddress")
';

EXEC sp_execute_external_script  
	@language = N'R',
	@script = @RScript,
	@output_data_1_name = N'People'
WITH RESULT SETS 
(
	(
		EmailAddress NVARCHAR(255)
	)
);
END
GO
