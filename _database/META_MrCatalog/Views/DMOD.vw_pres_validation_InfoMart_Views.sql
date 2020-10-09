SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_pres_validation_InfoMart_Views] AS
SELECT
	  [InfoMartDatabaseName] AS [InfoMart Database Name]
	, [ViewSchema] AS [Schema]
	, [ViewName] AS [View Name]
	, [ValidationStatus] AS [Validation Status]
	, [ValidationMessage] AS [Validation Messgae]
	, [LastValidationDate] AS [Last Validation Date]
  FROM [DMOD].[Validation_InfoMart_Views]

GO
