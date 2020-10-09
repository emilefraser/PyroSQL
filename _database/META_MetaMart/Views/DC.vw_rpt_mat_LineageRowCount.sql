SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DC].[vw_rpt_mat_LineageRowCount] AS 
select 1 test/*
SELECT
	VaultDatabaseName
	, VaultDatabaseName + '.' + VaultSchemaName + '.' + VaultTableName AS VaultEntity
	, VaultRowCount
	, StageDatabaseName + '.' + StageSchemaName + '.' + StageTableName AS StageEntity
	, StageRowCount 
	, ODSDatabaseName + '.' + ODSSchemaName + '.' + ODSTableName AS ODSEntity
	, ODSRowCount 
FROM DC.vw_rpt_LineageRowCount
GO
PRINT N'Creating [DC].[vw_rpt_TableRowcounts]...';
*/

GO
