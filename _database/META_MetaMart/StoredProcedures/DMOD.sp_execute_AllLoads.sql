SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Loading/Load Testing of Stage Tables & Vault Talbes
	How? 
		
		DECLARE @Today DATETIME2(7) = (SELECT GETDATE())
		DECLARE @IsInitialLoad BIT = 1
		DECLARE @IsTestLoad BIT = 0
		DECLARE @DatabaseEnvironmentType VARCHAR(20) = 'DEV'
		DECLARE @IsTruncateDataVaultTablesBeforeLoading BIT = 0
		
		EXEC DMOD.[sp_execute_AllLoads] @Today = @Today, @IsInitialLoad = @IsInitialLoad, @IsTestLoad = @IsTestLoad, @DatabaseEnvironmentType = @DatabaseEnvironmentType
		, @IsTruncateDataVaultTablesBeforeLoading = @IsTruncateDataVaultTablesBeforeLoading
*/

CREATE        PROCEDURE [DMOD].[sp_execute_AllLoads]
	@Today VARCHAR(100), @IsInitialLoad BIT, @IsTestLoad BIT, @DatabaseEnvironmentType VARCHAR(20), @IsTruncateDataVaultTablesBeforeLoading BIT
AS

-- Gets DatabaseName for the Loading StageArea (DEV,PROD...)
	DECLARE @DatabaseName_StageArea VARCHAR(200) = (SELECT 
														db.DatabaseName
													FROM 
														DC.[Database] AS db 
													INNER JOIN 
														DC.[DatabasePurpose] AS dp 
														ON dp.DatabasePurposeID = db.DatabasePurposeID
													INNER JOIN 
														TYPE.[Generic_Detail] AS gd
														ON gd.DetailID = db.DatabaseEnvironmentTypeID
													INNER JOIN 
														TYPE.[Generic_Header] AS gh
														ON gh.HeaderID = gd.HeaderID
													WHERE 
														DatabasePurposeCode = 'StageArea'
													AND 
														gd.DetailTypeCode = @DatabaseEnvironmentType
													)

-- Gets DatabaseName for the Loading the DataVault (DEV,PROD...)
DECLARE @DatabaseName_DataVault VARCHAR(200) = (SELECT 
													db.DatabaseName
												FROM 
													DC.[Database] AS db 
												INNER JOIN 
													DC.[DatabasePurpose] AS dp 
													ON dp.DatabasePurposeID = db.DatabasePurposeID
												INNER JOIN 
													TYPE.[Generic_Detail] AS gd
													ON gd.DetailID = db.DatabaseEnvironmentTypeID
												INNER JOIN 
													TYPE.[Generic_Header] AS gh
													ON gh.HeaderID = gd.HeaderID
												WHERE 
													DatabasePurposeCode = 'DataVault'
												AND 
													gd.DetailTypeCode = @DatabaseEnvironmentType
												)

-- RUN STAGE LOADS
EXEC DMOD.sp_execute_AllLoads_StageArea 
	@Today = @Today		
,	@IsInitialLoad = @IsInitialLoad
,	@IsTestLoad = @IsTestLoad
,	@DatabaseName = @DatabaseName_StageArea

-- RUN DATAVAULT LOADS
EXEC DMOD.sp_execute_AllLoads_DataVault
	@Today = @Today		
,	@IsTestLoad = @IsTestLoad
,	@DatabaseName = @DatabaseName_DataVault
,	@IsTruncateDataVaultTablesBeforeLoading = @IsTruncateDataVaultTablesBeforeLoading
GO
