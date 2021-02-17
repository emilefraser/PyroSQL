/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	Creates a Dynamic SQL Insert Statement

	(Usage)	
					SELECT * FROM [template].[ObjectName] (@Parameter1, @Parameter2)
	(/Usage)
##}}
*/

USE [template].[ObjectName]
GO

CREATE OR ALTER FUNCTION [template].[ObjectName] (
	@Parameter1		INT
,	@Parameter2		INT		= NULL
)

RETURNS INT
AS
BEGIN
     RETURN @Parameter1 * @Parameter2
END

