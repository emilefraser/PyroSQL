SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[template].[StoredProcedure_Template_WithError2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [template].[StoredProcedure_Template_WithError2] AS' 
END
GO
-- ======================================================
-- Author:		Emile Fraser
-- Create date: 2020-01-31
-- Description:	Standard Stored Procedure Pattern (with error handling)
-- ======================================================
---------------------------------------------------------
-- Prerun: 
---------------------------------------------------------
-- Test: 
/*
    DECLARE @Param1 INT = 10
    DECLARE @Param2 INT = 20
    DECLARE @Param3 INT
    EXEC MASTER.StoredProcedure_Template_WithError
			    @Param1 = @Param1
		    ,	@Param2 = @Param2 
            ,	@Param3 = @Param3 OUTPUT
    PRINT(CONVERT(VARCHAR(MAX), @Param3))
    SELECT * FROM dbo.ActionTable
    truncate table  dbo.ActionTable
*/
-- ======================================================
ALTER   PROCEDURE [template].[StoredProcedure_Template_WithError2]
	@Param1 INT
,	@Param2 INT = 0
,	@Param3 INT OUTPUT
AS
BEGIN
    -- This is only allowable statement before TRY
	SET XACT_ABORT, NOCOUNT ON
	   
	BEGIN TRY
		
		BEGIN TRANSACTION

            DECLARE @errno  INT
                 ,  @errmsg NVARCHAR(4000)
                 ,  @errmsg_aug NVARCHAR(4000)

            -- Perform Some Action
            DROP TABLE IF EXISTS dbo.ActionTable2
            CREATE TABLE dbo.ActionTable2 (a INT NOT NULL, b INT NOT NULL)
			INSERT dbo.ActionTable2(a, b) VALUES (@Param1, @Param2)
			INSERT dbo.ActionTable2(a, b) VALUES (@Param1, @Param2)

            CREATE UNIQUE NONCLUSTERED INDEX ix_01 ON dbo.ActionTable2(a)
            SET @Param3 = (SELECT SUM(a + b) FROM dbo.ActionTable)

		COMMIT TRANSACTION
		
	END TRY
   
	BEGIN CATCH

	EXEC DataManager_Local.ERR.Error_Handle
                    @ProcedureID  = @@PROCID
                 ,  @IsReraiseError = 1
                 ,  @ErrorNumber  = @errno OUTPUT
                 ,  @ErrorMessage  = @errmsg OUTPUT
                 ,  @ErrorMessage_Augmented  = @errmsg_aug OUTPUT

    END CATCH
END


GO
