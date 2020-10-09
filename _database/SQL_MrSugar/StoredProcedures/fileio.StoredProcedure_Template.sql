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
CREATE   PROCEDURE fileio.StoredProcedure_Template
	@Param1 INT
,	@Param2 INT = 0
,	@Param3 INT OUTPUT
AS
BEGIN
    -- This is only allowable statement before TRY
	SET XACT_ABORT, NOCOUNT ON
	   
	BEGIN TRY
		
		BEGIN TRANSACTION

            -- Perform Some Action
            DROP TABLE IF EXISTS dbo.ActionTable
            CREATE TABLE dbo.ActionTable (a INT PRIMARY KEY, b INT NOT NULL)
			INSERT dbo.ActionTable(a, b) VALUES (@Param1, @Param2)
			INSERT dbo.ActionTable(a, b) VALUES (@Param1, @Param2)
            SET @Param3 = (SELECT SUM(a + b) FROM dbo.ActionTable)
		COMMIT TRANSACTION
		
	END TRY
   
	BEGIN CATCH

		-- Test XACT_STATE for 0, 1, or -1 (Must Have enabled XACT_ABORT ON)
        -- Transaction is active and valid thus commitable
		IF (XACT_STATE() > 0 AND @@TRANCOUNT > 0)
        BEGIN
            SET @Param3 = (SELECT SUM(a + b) FROM dbo.ActionTable)
			COMMIT TRANSACTION
            RETURN 0
        END

	    -- Transaction is not uncommittable and should be rolled back	
		ELSE IF (XACT_STATE() < 0 AND @@trancount > 0)
        BEGIN
            ;THROW
			ROLLBACK TRANSACTION
            RETURN 55555
		END

        -- There is no transction, trying to commit would generate error
        ELSE IF (XACT_STATE() = 0 OR  @@TRANCOUNT = 0) 
        BEGIN
            ;THROW
            RAISERROR('No Active Transactions', 0,  1)            
            RETURN 55555
        END

        -- Run for the hills, our SQL instance has been corrupted
        ELSE 
        BEGIN
            RAISERROR('******************************** ERROR *******************************', 16, 1)
            RAISERROR('A serious error has occured, please contact your DBA immediately', 16, 1)
            RAISERROR('These commands need to be run, to prevent catastrophic data loss:', 16, 1)
            RAISERROR('USE master', 16, 1)
            RAISERROR('GO', 16, 1)
            RAISERROR('ALTER DATABASE DB_NAME() SET SINGLE_USER WITH ROLLBACK IMMEDIATE', 16, 1)
            RAISERROR('GO', 16, 1)
            RAISERROR('ALTER DATABASE DB_NAME() SET READ_ONY', 16, 1)
            RAISERROR('GO', 16, 1)

            RETURN 55555
        END
    END CATCH
END



GO
