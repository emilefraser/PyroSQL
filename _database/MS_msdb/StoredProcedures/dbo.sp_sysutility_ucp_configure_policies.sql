SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_configure_policies]
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @condition_id INT
    DECLARE @object_set_id INT
    DECLARE @target_set_id INT
    DECLARE @policy_id INT
    DECLARE @computer_urn NVARCHAR(4000)
    DECLARE @dac_urn NVARCHAR(4000)
    DECLARE @server_urn NVARCHAR(4000)
    DECLARE @start DATETIME

    SELECT @start = getdate()

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Delete existing Policies, Conditions, objectSets and Schedule
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityComputerProcessorOverUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityComputerProcessorOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityComputerProcessorOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityComputerProcessorOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityComputerProcessorOverUtilizationCondition'
    END

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityComputerProcessorOverUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorOverUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityComputerProcessorOverUtilizationTargetCondition'
    END

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityComputerProcessorUnderUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityComputerProcessorUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityComputerProcessorUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityComputerProcessorUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityComputerProcessorUnderUtilizationCondition'
    END   

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityComputerProcessorUnderUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorUnderUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityComputerProcessorUnderUtilizationTargetCondition'
    END   

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacDataFileSpaceOverUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacDataFileSpaceOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacDataFileSpaceOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacDataFileSpaceOverUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacDataFileSpaceUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacDataFileSpaceUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacDataFileSpaceUnderUtilizationCondition'
    END   

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacLogFileSpaceOverUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacLogFileSpaceOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacLogFileSpaceOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacLogFileSpaceOverUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacLogFileSpaceUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacLogFileSpaceUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacLogFileSpaceUnderUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerDataFileSpaceOverUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerDataFileSpaceOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerDataFileSpaceOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerDataFileSpaceOverUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerDataFileSpaceUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerDataFileSpaceUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerDataFileSpaceUnderUtilizationCondition'
    END   

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerLogFileSpaceOverUtilizationPolicy')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerLogFileSpaceOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerLogFileSpaceOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerLogFileSpaceOverUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerLogFileSpaceUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerLogFileSpaceUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerLogFileSpaceUnderUtilizationCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerProcessorOverUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerProcessorOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerProcessorOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerProcessorOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerProcessorOverUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerProcessorOverUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorOverUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerProcessorOverUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityServerProcessorUnderUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerProcessorUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityServerProcessorUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerProcessorUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerProcessorUnderUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityServerProcessorUnderUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorUnderUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityServerProcessorUnderUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacProcessorOverUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacProcessorOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacProcessorOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacProcessorOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacProcessorOverUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacProcessorOverUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorOverUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacProcessorOverUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityDacProcessorUnderUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacProcessorUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityDacProcessorUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacProcessorUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacProcessorUnderUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityDacProcessorUnderUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorUnderUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityDacProcessorUnderUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityVolumeSpaceOverUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityVolumeSpaceOverUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityVolumeSpaceOverUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityVolumeSpaceOverUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceOverUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityVolumeSpaceOverUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityVolumeSpaceOverUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceOverUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityVolumeSpaceOverUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT policy_id FROM msdb.dbo.syspolicy_policies WHERE name=N'UtilityVolumeSpaceUnderUtilizationPolicy')
    BEGIN
    	EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityVolumeSpaceUnderUtilizationPolicy', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_policy @name=N'UtilityVolumeSpaceUnderUtilizationPolicy'
    END    

    IF EXISTS(SELECT object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet')
    BEGIN   
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_object_set @object_set_name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityVolumeSpaceUnderUtilizationCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceUnderUtilizationCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityVolumeSpaceUnderUtilizationCondition'
    END    

    IF EXISTS(SELECT condition_id FROM msdb.dbo.syspolicy_conditions WHERE name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition')
    BEGIN
        EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition', @marker=0
        EXEC msdb.dbo.sp_syspolicy_delete_condition @name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition'
    END    

    IF EXISTS(SELECT COUNT(*) FROM msdb.dbo.sysutility_ucp_health_policies_internal)
    BEGIN
        DELETE FROM msdb.dbo.sysutility_ucp_health_policies_internal
    END    

    IF EXISTS(SELECT schedule_id FROM msdb.dbo.sysschedules WHERE name=N'UtilityResourceHealthStateSchedule')
    BEGIN
        EXEC msdb.dbo.sp_delete_schedule @schedule_name=N'UtilityResourceHealthStateSchedule', @force_delete=1
    END 

    IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Utility Resource Health State')
    BEGIN
        EXEC msdb.dbo.sp_delete_job @job_name=N'Utility Resource Health State', @delete_unused_schedule=1
    END

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityComputerProcessorOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityComputerProcessorOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU overutilization policy is satisfied for a computer that hosts a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Computer', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id
    
    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorOverUtilizationCondition', @marker=1


    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityComputerProcessorOverUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU overutilization policy is violated for a computer that hosts a managed instance of SQL Server. This condition is used by the utility control point to query the computers.', 
    @facet=N'Computer', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id
        
    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorOverUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityComputerProcessorUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityComputerProcessorUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU underutilization policy is satisfied for a computer that hosts a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Computer', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorUnderUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityComputerProcessorUnderUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU underutilization policy is violated for a computer that hosts a managed instance of SQL Server. This condition is used by the utility control point to query the computers.', 
    @facet=N'Computer', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityComputerProcessorUnderUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacDataFileSpaceOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacDataFileSpaceOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the data file space overutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'IDataFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacDataFileSpaceOverUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacDataFileSpaceUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacDataFileSpaceUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the data file space underutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'IDataFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacDataFileSpaceUnderUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacLogFileSpaceOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacLogFileSpaceOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the log file space overutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'ILogFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacLogFileSpaceOverUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacLogFileSpaceUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacLogFileSpaceUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the log file space underutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'ILogFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacLogFileSpaceUnderUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerDataFileSpaceOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerDataFileSpaceOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the data file space overutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'IDataFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerDataFileSpaceOverUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerDataFileSpaceUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerDataFileSpaceUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the data file space underutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'IDataFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerDataFileSpaceUnderUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerLogFileSpaceOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerLogFileSpaceOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the log file space overutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'ILogFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerLogFileSpaceOverUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerLogFileSpaceUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerLogFileSpaceUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the log file space underutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'ILogFilePerformanceFacet', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>SpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerLogFileSpaceUnderUtilizationCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerProcessorOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerProcessorOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU overutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Server', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUsage</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorOverUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerProcessorOverUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU overutilization policy is violated for a managed instance of SQL Server. This condition is used by the utility control point to query the managed instances of SQL Server.', 
    @facet=N'Server', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUsage</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorOverUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerProcessorUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerProcessorUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU underutilization policy is satisfied for a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Server', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUsage</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorUnderUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityServerProcessorUnderUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU underutilization policy is violated for a managed instance of SQL Server. This condition is used by the utility control point to query the managed instances of SQL Server.', 
    @facet=N'Server', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUsage</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityServerProcessorUnderUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacProcessorOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacProcessorOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU overutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'DeployedDac', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorOverUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacProcessorOverUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU overutilization policy is violated for a deployed data-tier application. This condition is used by the utility control point to query the deployed data-tier applications. ', 
    @facet=N'DeployedDac', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorOverUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacProcessorUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacProcessorUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the CPU underutilization policy is satisfied for a deployed data-tier application. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'DeployedDac', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorUnderUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityDacProcessorUnderUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the CPU underutilization policy is violated for a deployed data-tier application. This condition is used by the utility control point to query the deployed data-tier applications. ', 
    @facet=N'DeployedDac', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ProcessorUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityDacProcessorUnderUtilizationTargetCondition', @marker=1

    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityVolumeSpaceOverUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityVolumeSpaceOverUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the volume space overutilization policy is satisfied for a computer that hosts a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Volume', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>TotalSpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceOverUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityVolumeSpaceOverUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the volume space overutilization policy is violated for a computer that hosts a managed instance of SQL Server. This condition is used by the utility control point to query the volumes.', 
    @facet=N'Volume', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>TotalSpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>70</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceOverUtilizationTargetCondition', @marker=1

    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityVolumeSpaceUnderUtilizationCondition
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityVolumeSpaceUnderUtilizationCondition', 
    @description=N'The SQL Server Utility condition that expresses when the volume space underutilization policy is satisfied for a computer that hosts a managed instance of SQL Server. The value that is used in the condition expression is set in SQL Server Utility Explorer.', 
    @facet=N'Volume', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>GE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>TotalSpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceUnderUtilizationCondition', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition', 
    @description=N'The SQL Server Utility condition that is used to determine whether the volume space underutilization policy is violated for a computer that hosts a managed instance of SQL Server. This condition is used by the utility control point to query the volumes. ', 
    @facet=N'Volume', @expression=N'<Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>LT</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>TotalSpaceUtilization</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
    Select @condition_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'CONDITION', @name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition', @marker=1

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityComputerProcessorOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet', @facet=N'Computer', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Computer', @type=N'COMPUTER', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer', @level_name=N'Computer', @condition_name=N'UtilityComputerProcessorOverUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityComputerProcessorOverUtilizationPolicy', @condition_name=N'UtilityComputerProcessorOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU overutilization on a computer that hosts a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityComputerProcessorOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityComputerProcessorOverUtilizationPolicy', @marker=1

    SELECT @computer_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Computer'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityComputerProcessorOverUtilizationPolicy',@rollup_object_type=3,@rollup_object_urn=@computer_urn,@target_type=1,@resource_type=3,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityComputerProcessorUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet', @facet=N'Computer', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Computer', @type=N'COMPUTER', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer', @level_name=N'Computer', @condition_name=N'UtilityComputerProcessorUnderUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityComputerProcessorUnderUtilizationPolicy', @condition_name=N'UtilityComputerProcessorUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU underutilization on a computer that hosts a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityComputerProcessorUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityComputerProcessorUnderUtilizationPolicy', @marker=1

    SELECT @computer_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Computer'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityComputerProcessorUnderUtilizationPolicy',@rollup_object_type=3,@rollup_object_urn=@computer_urn,@target_type=1,@resource_type=3,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacDataFileSpaceOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet', @facet=N'IDataFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy', @condition_name=N'UtilityDacDataFileSpaceOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for data file space overutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacDataFileSpaceOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacDataFileSpaceOverUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacDataFileSpaceOverUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=2,@resource_type=1,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacDataFileSpaceUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet', @facet=N'IDataFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy', @condition_name=N'UtilityDacDataFileSpaceUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for data file space underutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacDataFileSpaceUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacDataFileSpaceUnderUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=2,@resource_type=1,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacLogFileSpaceOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet', @facet=N'ILogFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/LogFile', @type=N'LOGFILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/LogFile', @level_name=N'LogFile', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy', @condition_name=N'UtilityDacLogFileSpaceOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for log file space overutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacLogFileSpaceOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacLogFileSpaceOverUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacLogFileSpaceOverUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=3,@resource_type=1,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacLogFileSpaceUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet', @facet=N'ILogFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/LogFile', @type=N'LOGFILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/LogFile', @level_name=N'LogFile', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy', @condition_name=N'UtilityDacLogFileSpaceUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for log file space underutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacLogFileSpaceUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacLogFileSpaceUnderUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=3,@resource_type=1,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerDataFileSpaceOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet', @facet=N'IDataFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy', @condition_name=N'UtilityServerDataFileSpaceOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for data file space overutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerDataFileSpaceOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerDataFileSpaceOverUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerDataFileSpaceOverUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=2,@resource_type=1,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerDataFileSpaceUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet', @facet=N'IDataFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy', @condition_name=N'UtilityServerDataFileSpaceUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for data file space underutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerDataFileSpaceUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerDataFileSpaceUnderUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=2,@resource_type=1,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerLogFileSpaceOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet', @facet=N'ILogFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/LogFile', @type=N'LOGFILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/LogFile', @level_name=N'LogFile', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy', @condition_name=N'UtilityServerLogFileSpaceOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for log file space overutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerLogFileSpaceOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerLogFileSpaceOverUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerLogFileSpaceOverUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=3,@resource_type=1,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerLogFileSpaceUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet', @facet=N'ILogFilePerformanceFacet', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server/Database/LogFile', @type=N'LOGFILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database/LogFile', @level_name=N'LogFile', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy', @condition_name=N'UtilityServerLogFileSpaceUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for log file space underutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerLogFileSpaceUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerLogFileSpaceUnderUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=3,@resource_type=1,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerProcessorOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'UtilityServerProcessorOverUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerProcessorOverUtilizationPolicy', @condition_name=N'UtilityServerProcessorOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU overutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerProcessorOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerProcessorOverUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerProcessorOverUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=4,@resource_type=3,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityServerProcessorUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Server', @level_name=N'Server', @condition_name=N'UtilityServerProcessorUnderUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityServerProcessorUnderUtilizationPolicy', @condition_name=N'UtilityServerProcessorUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU underutilization on a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityServerProcessorUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityServerProcessorUnderUtilizationPolicy', @marker=1

    SELECT @server_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Server'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityServerProcessorUnderUtilizationPolicy',@rollup_object_type=2,@rollup_object_urn=@server_urn,@target_type=4,@resource_type=3,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacProcessorOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet', @facet=N'DeployedDac', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/DeployedDac', @type=N'DEPLOYEDDAC', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/DeployedDac', @level_name=N'DeployedDac', @condition_name=N'UtilityDacProcessorOverUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacProcessorOverUtilizationPolicy', @condition_name=N'UtilityDacProcessorOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU overutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacProcessorOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacProcessorOverUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacProcessorOverUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=5,@resource_type=3,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityDacProcessorUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet', @facet=N'DeployedDac', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/DeployedDac', @type=N'DEPLOYEDDAC', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/DeployedDac', @level_name=N'DeployedDac', @condition_name=N'UtilityDacProcessorUnderUtilizationTargetCondition', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityDacProcessorUnderUtilizationPolicy', @condition_name=N'UtilityDacProcessorUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for CPU underutilization for a deployed data-tier application.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityDacProcessorUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityDacProcessorUnderUtilizationPolicy', @marker=1

    SELECT @dac_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/DeployedDac'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityDacProcessorUnderUtilizationPolicy',@rollup_object_type=1,@rollup_object_urn=@dac_urn,@target_type=5,@resource_type=3,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityVolumeSpaceOverUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet', @facet=N'Volume', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Computer/Volume', @type=N'VOLUME', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer/Volume', @level_name=N'Volume', @condition_name=N'UtilityVolumeSpaceOverUtilizationTargetCondition', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer', @level_name=N'Computer', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityVolumeSpaceOverUtilizationPolicy', @condition_name=N'UtilityVolumeSpaceOverUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for volume space overutilization on a computer that hosts a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityVolumeSpaceOverUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityVolumeSpaceOverUtilizationPolicy', @marker=1

    SELECT @computer_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Computer'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityVolumeSpaceOverUtilizationPolicy',@rollup_object_type=3,@rollup_object_urn=@computer_urn,@target_type=6,@resource_type=1,@utilization_type=2,@utilization_threshold=70

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- UtilityVolumeSpaceUnderUtilizationPolicy
    -------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet', @facet=N'Volume', @object_set_id=@object_set_id OUTPUT
    Select @object_set_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'OBJECTSET', @name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet', @marker=1

    EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet', @type_skeleton=N'Utility/Computer/Volume', @type=N'VOLUME', @enabled=True, @target_set_id=@target_set_id OUTPUT
    Select @target_set_id

    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer/Volume', @level_name=N'Volume', @condition_name=N'UtilityVolumeSpaceUnderUtilizationTargetCondition', @target_set_level_id=0
    EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Utility/Computer', @level_name=N'Computer', @condition_name=N'', @target_set_level_id=0

    EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'UtilityVolumeSpaceUnderUtilizationPolicy', @condition_name=N'UtilityVolumeSpaceUnderUtilizationCondition', @policy_category=N'', 
    @description=N'The SQL Server Utility policy that checks for volume space underutilization on a computer that hosts a managed instance of SQL Server.', 
    @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'UtilityVolumeSpaceUnderUtilizationPolicy_ObjectSet'
    Select @policy_id

    EXEC msdb.dbo.sp_syspolicy_mark_system @type=N'POLICY', @name=N'UtilityVolumeSpaceUnderUtilizationPolicy', @marker=1

    SELECT @computer_urn = 'Utility[@Name='''+CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName'))+''']/Computer'
    EXEC msdb.dbo.sp_sysutility_ucp_add_policy @policy_name=N'UtilityVolumeSpaceUnderUtilizationPolicy',@rollup_object_type=3,@rollup_object_urn=@computer_urn,@target_type=6,@resource_type=1,@utilization_type=1,@utilization_threshold=0

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Update sysutility_ucp_health_policies_internal entries to system policies 
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    IF EXISTS(SELECT COUNT(*) FROM msdb.dbo.sysutility_ucp_health_policies_internal)
    BEGIN
        UPDATE msdb.dbo.sysutility_ucp_health_policies_internal SET is_global_policy = 1
    END    
    
    -- Compute default health states during UCP creation (boot strap scenario)
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_health
    
    --**********************************************************************
    -- Mark all newly created sp_sysutility* artifacts as system.
    -- (code extracted and modified from "Mark system objects" in instdb.sql.)
    --**********************************************************************
    BEGIN
        declare @name sysname;
        declare newsysobjs cursor for select name from sys.objects where schema_id = 1 and name LIKE '%sysutility%' and create_date >= @start 
        open newsysobjs
        fetch next from newsysobjs into @name
        while @@fetch_status = 0
        begin
            Exec sp_MS_marksystemobject @name
            fetch next from newsysobjs into @name
        end
        deallocate newsysobjs
    END

END

GO
