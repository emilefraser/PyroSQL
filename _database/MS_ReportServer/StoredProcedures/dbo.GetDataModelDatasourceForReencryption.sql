SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDataModelDatasourceForReencryption]
@DSID as bigint
AS

SELECT
    [ConnectionString],
    [Username],
    [Password]
FROM [dbo].[DataModelDataSource]
WHERE [DSID] = @DSID
GO
