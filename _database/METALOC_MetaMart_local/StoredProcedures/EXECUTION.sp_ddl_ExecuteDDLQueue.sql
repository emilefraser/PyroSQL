SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [EXECUTION].[sp_ddl_ExecuteDDLQueue]
AS
DECLARE @SqlText VARCHAR(MAX)
DECLARE @DDLExecutionQueueID INT
 
DECLARE DDLCursor CURSOR FOR   
    SELECT DDLQueryText , DDLExecutionQueueID
    FROM [INTEGRATION].ingress_DDLExecutionQueue
    WHERE [Result] = 'Pending'      
OPEN DDLCursor  
FETCH NEXT FROM DDLCursor   
INTO @SqlText, @DDLExecutionQueueID  
WHILE @@FETCH_STATUS = 0  
BEGIN   
    BEGIN TRY 
        --Execute the SQL from the queue     
        EXEC (@SqlText) 
        --Log success
        INSERT INTO [LOG].[DDLExecutionLog]
           ([DDLQueryText]
           ,[DDLExecutionQueueID]
           ,[Result]
           ,[ErrorID]
           ,[ErrorMessage]
           ,[CreatedDT]) 
           VALUES (  
                    @SqlText
                    ,@DDLExecutionQueueID
                    ,'Success'
                    ,NULL
                    ,NULL
                    ,GETDATE()
                    ) 
    END TRY  
    BEGIN CATCH
        --Log error
        INSERT INTO [LOG].[DDLExecutionLog]
           ([DDLQueryText]
           ,[DDLExecutionQueueID]
           ,[Result]
           ,[ErrorID]
           ,[ErrorMessage]
           ,[CreatedDT])   
        SELECT
            @SqlText
            ,@DDLExecutionQueueID
            ,'Error'   
            ,ERROR_NUMBER()  
            ,ERROR_MESSAGE()
            ,GETDATE() 
    END CATCH 
  
    FETCH NEXT FROM DDLCursor   
    INTO @SqlText, @DDLExecutionQueueID  
END  
 
CLOSE DDLCursor 
DEALLOCATE DDLCursor
--Clear the queue
TRUNCATE TABLE [INTEGRATION].[ingress_DDLExecutionQueue]




GO
