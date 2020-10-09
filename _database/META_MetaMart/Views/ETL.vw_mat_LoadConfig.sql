SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_mat_LoadConfig] AS
SELECT 
LoadConfigID AS [Load Config ID],
SourceDataEntityID AS [Source Data Entity ID],
TargetDataEntityID AS [Target Data Entity ID],
LoadTypeID AS [Load Type ID],
PrimaryKeyField AS [Primary Key Field],
CreatedDTField AS [Created DT Field],
IsSetForReloadOnNextRun AS [Is Set For Reload On Next Run],
NewDataFilterType AS [New Data Filter Type],
OffsetDays AS [Offset Days],
TransactionNoField AS [Transaction No Field],
UpdatedDTField AS [Updated DT Field],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
isActive AS [is Active]
FROM [ETL].[LoadConfig]

GO
