SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
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
    BEGIN TRY
    DECLARE @Param1 INT = 10
    DECLARE @Param2 INT = 20
    DECLARE @Param3 INT
    EXEC MASTER.StoredProcedure_Template_WithError2
			    @Param1 = @Param1
		    ,	@Param2 = @Param2 
            ,	@Param3 = @Param3 OUTPUT
    PRINT(CONVERT(VARCHAR(MAX), @Param3))
    END TRY
    BEGIN CATCH
        ;THROW
    END CATCH
*/
-- ======================================================
CREATE     PROCEDURE [MASTER].[StoredProcedure_Template_WithError2]
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
