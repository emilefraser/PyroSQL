SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_add_policy] 
   @policy_name SYSNAME,
   @rollup_object_type INT,
   @rollup_object_urn NVARCHAR(4000),
   @target_type INT,
   @resource_type INT,
   @utilization_type INT,
   @utilization_threshold FLOAT,
   @resource_health_policy_id INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN

    DECLARE @retval INT
    DECLARE @null_column    SYSNAME
    
    SET @null_column = NULL

    IF (@policy_name IS NULL OR @policy_name = N'')
        SET @null_column = '@policy_name'
    ELSE IF (@rollup_object_type IS NULL OR @rollup_object_type < 1 OR @rollup_object_type > 3)
        SET @null_column = '@rollup_object_type'
    ELSE IF (@rollup_object_urn IS NULL OR @rollup_object_urn = N'')
        SET @null_column = '@rollup_object_urn'
    ELSE IF (@target_type IS NULL OR @target_type < 1 OR @target_type > 6)
        SET @null_column = '@target_type'
    ELSE IF (@resource_type IS NULL OR @resource_type < 1 OR @resource_type > 5)
        SET @null_column = '@resource_type'
    ELSE IF (@utilization_type IS NULL OR @utilization_type < 1 OR @utilization_type > 2)
        SET @null_column = '@utilization_type'
    ELSE IF (@utilization_threshold IS NULL OR @utilization_threshold < 0 OR @utilization_threshold > 100)
        SET @null_column = '@utilization_threshold'       
    
    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_add_policy')
        RETURN(1)
    END

    IF NOT EXISTS (SELECT * FROM dbo.syspolicy_policies WHERE name = @policy_name)
    BEGIN
        RAISERROR(14027, -1, -1, @policy_name)
        RETURN(1)
    END

    INSERT INTO dbo.sysutility_ucp_health_policies_internal(policy_name, rollup_object_type, rollup_object_urn, target_type, resource_type, utilization_type, utilization_threshold)
    VALUES(@policy_name, @rollup_object_type, @rollup_object_urn, @target_type, @resource_type, @utilization_type, @utilization_threshold)
    
    SELECT @retval = @@error
    SET @resource_health_policy_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
