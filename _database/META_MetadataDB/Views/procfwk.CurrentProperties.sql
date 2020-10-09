SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [procfwk].[CurrentProperties]
AS

SELECT
	[PropertyName],
	[PropertyValue]
FROM
	[procfwk].[Properties]
WHERE
	[ValidTo] IS NULL;

GO
