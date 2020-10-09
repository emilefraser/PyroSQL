SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_mat_ODSLoadConfigDetails]
AS
SELECT        TOP (100) PERCENT 
				LC.LoadConfigID, 
				LC.SourceDataEntityID, 
				SRC.ServerName AS SourceServerName, 
				SRC.ServerLocationID AS [Source Server Location ID], 
				Sourcesl.ServerLocationCode AS [Source Server Location Code],
 				Sourcesl.ServerLocationName AS [Source Server Location Name], 
				Sourcesl.IsCloudLocation AS [Source Is Cloud Location], 
				SRC.DatabaseInstanceName AS SourceDatabaseInstanceName, 
                SRC.DatabaseName AS SourceDatabaseName, 
				SRC.SchemaName AS SourceSchemaName, 
				SRC.DataEntityName AS SourceDataEntityName, 
				LC.TargetDataEntityID, 
                vw_rpt_DistinctDataEntityDetail_1.ServerName AS TargetServerName, 
				vw_rpt_DistinctDataEntityDetail_1.ServerLocationID AS [Target Server Location ID], 
				targetsl.ServerLocationCode AS [Target Server Location Code],
 				targetsl.ServerLocationName AS [Target Server Location Name], 
				targetsl.IsCloudLocation AS [Target Is Cloud Location], 
				vw_rpt_DistinctDataEntityDetail_1.DatabaseInstanceName AS TargetDatabaseInstanceName, 
                vw_rpt_DistinctDataEntityDetail_1.DatabaseName AS TargetDatabaseName, 
				vw_rpt_DistinctDataEntityDetail_1.SchemaName AS TargetSchemaName, 
                vw_rpt_DistinctDataEntityDetail_1.DataEntityName AS TargetDataEntityName, 
				SH.ScheduleExecutionIntervalMinutes, 
				SH.ScheduleExecutionTime, 
				LC.LoadTypeID, 
				LT.LoadTypeCode, 
				LT.LoadTypeName,
                LC.IsSetForReloadOnNextRun, 
				LC.OffsetDays, 
				LC.NewDataFilterType, 
				LC.PrimaryKeyField, 
				LC.TransactionNoField, 
				LC.CreatedDTField, 
				LC.UpdatedDTField, 
				SH.IsActive, 
				SH.CreatedDT, 
				SH.UpdatedDT

FROM            ETL.LoadConfig AS LC 
				INNER JOIN SCHEDULER.SchedulerHeader AS SH 
				ON LC.LoadConfigID = SH.ETLLoadConfigID 
				INNER JOIN ETL.LoadType AS LT 
				ON LC.LoadTypeID = LT.LoadTypeID 
				INNER JOIN DC.vw_rpt_DistinctDataEntityDetail AS SRC 
				ON LC.SourceDataEntityID = SRC.DataEntityID 
				LEFT JOIN DC.ServerLocation Sourcesl 
				ON Sourcesl.ServerLocationID = SRC.ServerLocationiD
				INNER JOIN DC.vw_rpt_DistinctDataEntityDetail AS vw_rpt_DistinctDataEntityDetail_1 
				ON LC.TargetDataEntityID = vw_rpt_DistinctDataEntityDetail_1.DataEntityID
				LEFT JOIN DC.ServerLocation targetsl 
				ON vw_rpt_DistinctDataEntityDetail_1.ServerLocationID = targetsl.ServerLocationID

GO
