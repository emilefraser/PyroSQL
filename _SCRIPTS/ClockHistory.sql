
-- 4 TABLES
TRUNCATE TABLE [StageArea].[XT].[dbo_ClockHistory_XT_KEYS]
TRUNCATE TABLE [StageArea].[XT].[dbo_ClockHistory_XT_KEYS_Hist]
TRUNCATE TABLE [StageArea].[XT].[dbo_ClockHistory_XT_HVD]
TRUNCATE TABLE [StageArea].[XT].[dbo_ClockHistory_XT_HVD_Hist]


-- 9 TABLES
-- first tier
TRUNCATE TABLE [DataVault].[RAW].[HUB_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[LINK_Direction_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[LINK_EmployeeContractor_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[LINK_EventType_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[LINK_Terminal_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[LINK_Tag_ClockHistory]
TRUNCATE TABLE [DataVault].[RAW].[SAT_ClockHistory_XT_HVD]

-- second toer
TRUNCATE TABLE [DataVault].[RAW].[LINK_Terminal_EventType_Direction_ClockHistory]

-- third tier
TRUNCATE tABLE [DataVault].[biz].[BridgeZone_Employee_ClockHistory]

-- STAGE 
DECLARE @Today DATETIME2(7) = GETDATE()
DECLARE @IsInitialLoad BIT = 1
DECLARE @IsTest BIT = 0

EXEC [StageArea].[XT].[sp_StageIncrementalWithNoHistoryLoads_SDS_XT_dbo_ClockHistory_XT_SDS] 
				@Today = @Today
			,	@IsInitialLoad = @IsInitialLoad
			,	@IsTest = @IsTest

EXEC [StageArea].[XT].[sp_StageIncrementalWithNoHistoryLoads_KEYS_XT_dbo_ClockHistory_XT_KEYS] 
				@Today = @Today
			,	@IsInitialLoad = @IsInitialLoad
			,	@IsTest = @IsTest

EXEC [StageArea].[XT].[sp_StageIncrementalWithNoHistoryLoads_HVD_XT_dbo_ClockHistory_XT_HVD] 
				@Today = @Today
			,	@IsInitialLoad = @IsInitialLoad
			,	@IsTest = @IsTest

