SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDataSourceForUpgrade]
@CurrentVersion int
AS
SELECT
    [DSID]
FROM
    [DataSource]
WHERE
    [Version] != @CurrentVersion
GO
