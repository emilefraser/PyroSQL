SET XACT_ABORT, NOCOUNT ON
BEGIN TRY 
BEGIN TRANSACTION

--DATAVAULT
DECLARE @Today DATETIME2(7) = GETDATE()
DECLARE @IsTest BIT = 0
DECLARE @RC_HUB INT = 0
DECLARE @RC_LINK1 INT = 0
DECLARE @RC_LINK2 INT = 0
DECLARE @RC_LINK3 INT = 0
DECLARE @RC_LINK4 INT = 0
DECLARE @RC_LINK5 INT = 0
DECLARE @RC_LINK6 INT = 0
DECLARE @RC_SAT INT = 0
DECLARE @RC_BRIDGE INT = 0

EXEC @RC_HUB = [DataVault].[raw].[sp_loadhub_XT_ClockHistory] @Today
EXEC @RC_LINK1 = [DataVault].[raw].[sp_loadlink_XT_EmployeeContractor_ClockHistory] @Today
EXEC @RC_LINK2 = [DataVault].[raw].[sp_loadlink_XT_EventType_ClockHistory] @Today
EXEC @RC_LINK3 = [DataVault].[raw].[sp_loadlink_XT_Direction_ClockHistory]  @Today
EXEC @RC_LINK4 = [DataVault].[raw].[sp_loadlink_XT_Terminal_ClockHistory] @Today
EXEC @RC_LINK5 = [DataVault].[raw].[sp_loadlink_XT_Tag_ClockHistory] @Today

EXEC @RC_SAT = [DataVault].[raw].[sp_loadsat_ClockHistory_XT_HVD] @Today

EXEC @RC_LINK5 = [DataVault].[raw].[sp_loadlink_XT_Terminal_EventType_Direction_ClockHistory] @Today

EXEC @RC_BRIDGE = [DataVault].[biz].[sp_loadbridge_BridgeZone_Employee_ClockHistory] @Today



IF(@RC_HUB + @RC_LINK1 + @RC_LINK2 + @RC_LINK3 + @RC_LINK4 + @RC_SAT + @RC_LINK5 + @RC_BRIDGE != 0)
BEGIN
	RAISERROR ('Error raised in TRY block of DATAVAULT', -- Message text.
		16, -- Severity.
		50000 -- State.
		);
END

COMMIT TRANSACTION 
END TRY

BEGIN CATCH

	-- Send to Error Handleer 
	EXEC DataManager_Local.ERR.Error_Handle
                    @ProcedureID  = @@PROCID
                 ,  @IsReraiseError = 1

END CATCH