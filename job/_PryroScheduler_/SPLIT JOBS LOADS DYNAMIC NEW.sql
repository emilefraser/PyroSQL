
--CREATE PROCEDURE #Create_LoadJobs
--BEGIN


--SELECT * FROM DataManager.DMOD.vw_LoadConfig
--WHERE Source_DEName LIKE '%vw_dmod_CustInvoiceTrans%'
--OR Source_DEName LIKE '%vw_DMOD_SalesInvoice%'
--vw_dmod_CustInvoiceTrans--vw_DMOD_SalesInvoice-- removes job step 1 from the job Weekly Sales Data Backup   
USE msdb  
GO  

DECLARE @CLRF CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @Code NVARCHAR(MAX)
DECLARE @Ensamble NVARCHAR(MAX) = N'SalesOrderLine'
DECLARE @JobName SYSNAME = N'VaultLoad_HUB_' + @Ensamble
DECLARE @JobSteps INT = 0
DECLARE @JobStep_Current INT = 1

SET @JobSteps = (
SELECT
    COUNT(1) AS CNT
FROM
    [msdb].[dbo].[sysjobsteps] AS [sJSTP]
    INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB]
        ON [sJSTP].[job_id] = [sJOB].[job_id]
        WHERE sJOB.name = 'VaultLoad_HUB_SalesOrderLine'
)


WHILE (@JobStep_Current < @JobSteps)
BEGIN
EXEC dbo.sp_delete_jobstep  
    @step_id = @JobStep_Current,    @job_name = @JobName    
    SET @JobStep_Current += 1
END







SET @Code = N'USE StageArea' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsInitialLoad BIT = 0' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE D365.sp_StageFullLoad_KEYS_D365_dbo_GoodsReceiptLine_D365_KEYS
                          @Today = @Today
                        , @IsInitialLoad = @IsInitialLoad
                        , @IsTest = @IsTest'


EXEC sp_add_jobstep  
    @job_name = @JobName, 
    @step_name = N'StageLoad - GoodsReceiptLine - KEYS',  
    @subsystem = N'TSQL',  
    @step_id = 1,
    @on_success_action=3,
    @command = @Code

SET @Code = N'USE StageArea' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsInitialLoad BIT = 0' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE D365.sp_StageFullLoad_MVD_D365_dbo_GoodsReceiptLine_D365_MVD
                          @Today = @Today
                        , @IsInitialLoad = @IsInitialLoad
                        , @IsTest = @IsTest'

EXEC sp_add_jobstep  
    @job_name = @JobName,   
    @step_name = N'StageLoad - GoodsReceiptLine - VELOCITY MVD',  
    @subsystem = N'TSQL',  
    @step_id = 2,
    @on_success_action=3,
    @command = @Code


    -------


SET @Code = N'USE DataVault' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE raw.raw.sp_loadhub_D365_GoodsReceiptLine
                          @Today = @Today
                        , @IsTest = @IsTest'

EXEC sp_add_jobstep  
    @job_name = @JobName, 
    @step_name = N'VaultLoad - GoodsReceiptLine - HUB',  
    @subsystem = N'TSQL',  
    @step_id = 3,
    @on_success_action=3,
    @command = @Code


SET @Code = N'USE DataVault' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE raw.sp_loadlink_D365_GoodsReceipt_GoodsReceiptLine
                          @Today = @Today
                        , @IsTest = @IsTest'



EXEC sp_add_jobstep  
    @job_name = @JobName, 
    @step_name = N'VaultLoad - GoodsReceiptLine - GoodsReceipt_GoodsReceiptLine LINK',  
    @subsystem = N'TSQL',  
    @step_id = 4,
    @on_success_action=3,
    @command = @Code


    

SET @Code = N'USE DataVault' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE raw.raw.sp_loadlink_D365_Stock_GoodsReceiptLine
                          @Today = @Today
                        , @IsTest = @IsTest'

EXEC sp_add_jobstep  
    @job_name = @JobName, 
    @step_name = N'VaultLoad - GoodsReceiptLine - Stock_GoodsReceiptLine LINK',  
    @subsystem = N'TSQL',  
    @step_id = 5,
    @on_success_action=3,
    @command = @Code



--SET @Code = N'USE DataVault' + @CLRF + @CLRF 
--SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
--SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
--SET @Code += N'EXECUTE raw.sp_loadlink_D365_SalesGroup_Customer
--                          @Today = @Today
--                        , @IsTest = @IsTest'

--EXEC sp_add_jobstep  
--    @job_name = @JobName, 
--    @step_name = N'VaultLoad - GoodsReceiptLine - sp_loadlink_D365_SalesGroup_Customer LINK',  
--    @subsystem = N'TSQL',  
--    @step_id = 6,
--    @on_success_action=3,
--    @command = @Code

    
SET @Code = N'USE DataVault' + @CLRF + @CLRF 
SET @Code += N'DECLARE @Today DATETIME2(7) = GETDATE() ' + @CLRF 
SET @Code += N'DECLARE @IsTest BIT = 0' + @CLRF + @CLRF 
SET @Code += N'EXECUTE raw.sp_loadsat_D365_GoodsReceiptLine_MVD 
                          @Today = @Today
                        , @IsTest = @IsTest'

EXEC sp_add_jobstep  
    @job_name = @JobName, 
    @step_name = N'VaultLoad - GoodsReceiptLine - SAT MVD',  
    @subsystem = N'TSQL',  
    @step_id = 7,
    @on_success_action=1,
    @command = @Code


END

--DECLARE @curs_entity AS CURSORT

--SET @curs_entity = CURSOR FOR   

--SELECT LoadConfigID, LoadTypeCode, DataEntityTypeCode, Target_SchemaName, Target_DEName, TargetDataEntityID
--FROM DataManager.DMOD.vw_LoadConfig
--WHERE Source_DEName LIKE '%vw_dmod_CustInvoiceTrans%'
--OR Source_DEName LIKE '%vw_DMOD_SalesInvoice%'



--SELECT * FROM 
--( 
--SELECT LoadConfigID, LoadTypeCode, DataEntityTypeCode, Target_SchemaName, Source_DEName, TargetDataEntityID
--FROM DataManager.DMOD.vw_LoadConfig
--WHERE Source_DEName LIKE '%vw_dmod_CustInvoiceTrans%'
--OR Source_DEName LIKE '%vw_DMOD_SalesInvoice%'
--) AS mq
--INNER JOIN 
--(
--SELECT LoadConfigID, LoadTypeCode, DataEntityTypeCode, Target_DB, Target_SchemaName, Target_DEName, SourceDataEntityID
--FROM DataManager.DMOD.vw_LoadConfig
--) AS sq
--ON sq.SourceDataEntityID = mq.TargetDataEntityID


--sp_StageIncrementalWithHistoryUpdateLoad_LVD_EMS_dbo_GeneralLedgerAccounts_EMS_LVD
--   StageIncrementalWithHistoryUpdateLoad_MVD

--DECLARE @Today datetime2(7) = GetDate() 
--DECLARE @IsInitialLoad BIT = 0
--DECLARE @IsTest BIT = 0

