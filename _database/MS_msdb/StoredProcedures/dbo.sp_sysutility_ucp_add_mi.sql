SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_add_mi]
   @instance_name sysname,
   @virtual_server_name sysname,
   @agent_proxy_account sysname,
   @cache_directory nvarchar(520),
   @management_state int,
   @instance_id int = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
   SET NOCOUNT ON
   
   DECLARE @retval INT
   
   DECLARE @null_column nvarchar(600)
   SET @null_column = NULL

    IF (@instance_name IS NULL OR @instance_name = N'')
        SET @null_column = '@instance_name'
    ELSE IF (@virtual_server_name IS NULL OR @virtual_server_name = N'')
        SET @null_column = '@virtual_server_name'
    ELSE IF (@management_state IS NULL)
        SET @null_column = '@management_state'
    ELSE IF (@agent_proxy_account IS NULL OR @agent_proxy_account = N'')
        SET @null_column = '@agent_proxy_account'    

    -- @cache_directory can be null or empty
    

   IF @null_column IS NOT NULL
   BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_add_mi')
        RETURN(1)
   END
   
   
    IF EXISTS (SELECT * FROM dbo.sysutility_ucp_managed_instances_internal WHERE (instance_name = @instance_name))
    BEGIN
        RAISERROR(34010, -1, -1, 'Managed_Instance', @instance_name)
        RETURN(1)
    END
       
    INSERT INTO [dbo].[sysutility_ucp_managed_instances_internal]
      (instance_name, virtual_server_name, agent_proxy_account, cache_directory, management_state)
    VALUES
      (@instance_name, @virtual_server_name, @agent_proxy_account, @cache_directory, @management_state)
      
       
    SELECT @retval = @@error
    SET @instance_id = SCOPE_IDENTITY()
    RETURN(@retval)
    
END 

GO
