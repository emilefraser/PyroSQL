SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_mi_disable_collection]
WITH EXECUTE AS OWNER
AS
BEGIN
   SET NOCOUNT ON;
   
   BEGIN TRY
   DECLARE @tran_name NVARCHAR(32) = N'sysutility_mi_disable_colle' -- transaction names can be no more than 32 characters

   BEGIN TRANSACTION @tran_name
      DECLARE @job_category sysname       = N'Utility - Managed Instance';
      DECLARE @job_category_id INT        = (SELECT category_id FROM msdb.dbo.syscategories WHERE name=@job_category AND category_class=1)
      
      DECLARE @collect_and_upload_job_name sysname              = N'sysutility_mi_collect_and_upload';
      DECLARE @collect_and_upload_job_id uniqueidentifier       = (SELECT jobs.job_id
                                                                   FROM [msdb].[dbo].[sysjobs] jobs
                                                                   WHERE jobs.name = @collect_and_upload_job_name 
                                                                   AND jobs.category_id = @job_category_id);
                                                                     
      -- Dac performance collection job varaibles
      DECLARE @dac_perf_job_name sysname              = N'sysutility_mi_collect_performance';
      DECLARE @dac_perf_job_id uniqueidentifier       = (SELECT jobs.job_id
                                                         FROM [msdb].[dbo].[sysjobs] jobs
                                                         WHERE jobs.name = @dac_perf_job_name 
                                                         AND jobs.category_id = @job_category_id);

      IF(@collect_and_upload_job_id IS NOT NULL)
      BEGIN
         EXEC msdb.dbo.sp_update_job @job_id=@collect_and_upload_job_id, @enabled=0;
      END
      
      IF(@dac_perf_job_id IS NOT NULL)
      BEGIN
         EXEC msdb.dbo.sp_update_job @job_id=@dac_perf_job_id, @enabled=0;
      END
     		   
   COMMIT TRANSACTION @tran_name
   END TRY
   
   BEGIN CATCH
        -- Roll back our transaction if it's still open
        IF (@@TRANCOUNT > 0)
        BEGIN
            ROLLBACK TRANSACTION;
        END;
 
        -- Rethrow the error.  Unfortunately, we can't retrow the exact same error number b/c RAISERROR 
        -- does not allow you to use error numbers below 13000.  We rethrow error 14684: 
        -- Caught error#: %d, Level: %d, State: %d, in Procedure: %s, Line: %d, with Message: %s
        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
        RAISERROR (14684, -1, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);
    END CATCH;
   
END

GO
