SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- procedure that processes an event and decides 
-- what binding should handle it
CREATE PROCEDURE [dbo].[sp_syspolicy_dispatch_event]  @event_data xml, @synchronous bit
AS
BEGIN
	-- disable these as the caller may not have SHOWPLAN permission
	SET STATISTICS XML OFF
	SET STATISTICS PROFILE OFF

	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	IF ( @synchronous = 0)
		PRINT CONVERT(nvarchar(max), @event_data)
	DECLARE @event_type sysname
	DECLARE @object_type sysname
	DECLARE @database sysname
	DECLARE @mode int
	DECLARE @filter_expression nvarchar(4000)
	DECLARE @filter_expression_skeleton nvarchar(4000)

    SET @mode = (case @synchronous when 1 then 1 else 2 end)

    -- These settings are necessary to read XML.
    SET ANSI_NULLS ON
    SET ANSI_PADDING ON
    SET ANSI_WARNINGS ON
    SET ARITHABORT ON
    SET CONCAT_NULL_YIELDS_NULL ON
    SET NUMERIC_ROUNDABORT OFF
    SET QUOTED_IDENTIFIER ON

    SET NOCOUNT ON 

    SELECT 
        @event_type = T.c.value('(EventType/text())[1]', 'sysname')
        , @database = T.c.value('(DatabaseName/text())[1]', 'sysname')
        , @object_type = T.c.value('(ObjectType/text())[1]', 'sysname')
    FROM   @event_data.nodes('/EVENT_INSTANCE') T(c)
    
    -- we are going to ignore events that affect subobjects
    IF  (@event_type = N'ALTER_DATABASE' AND 
        1 = @event_data.exist('EVENT_INSTANCE/AlterDatabaseActionList')) OR
        (@event_type = N'ALTER_TABLE' AND 
        1 = @event_data.exist('EVENT_INSTANCE/AlterTableActionList'))
    BEGIN
        RETURN;
    END

    -- convert trace numerical objecttypes to string
    IF (ISNUMERIC(@object_type) = 1)
        select @object_type = name from master.dbo.spt_values where type = 'EOB' and number = @object_type

    -- these events do not have ObjectType and ObjectName
    IF ((@object_type IS NULL) AND @event_type IN ('CREATE_DATABASE', 'DROP_DATABASE', 'ALTER_DATABASE'))
    BEGIN
        SET @object_type = 'DATABASE'
    END

    INSERT msdb.dbo.syspolicy_execution_internal
        SELECT p.policy_id , @synchronous, @event_data
        FROM dbo.syspolicy_policies p  -- give me all the policies
        INNER JOIN dbo.syspolicy_conditions_internal c ON c.condition_id = p.condition_id  -- and their conditions
        INNER JOIN dbo.syspolicy_facet_events fe ON c.facet_id = fe.management_facet_id  -- and the facet events that are affected by the condition
        INNER JOIN dbo.syspolicy_target_sets ts ON ts.object_set_id = p.object_set_id AND ts.type = fe.target_type  -- and the target sets in the object set of the policy, with event types that are affected by the condition
        LEFT JOIN dbo.syspolicy_policy_category_subscriptions pgs ON pgs.policy_category_id = p.policy_category_id -- and the policy category subscriptions, if any
        LEFT JOIN dbo.syspolicy_target_set_levels tsl ON tsl.target_set_id = ts.target_set_id AND tsl.level_name = 'Database' -- and the database target set levels associated with any of the target sets, if any
        LEFT JOIN dbo.syspolicy_conditions_internal lc ON lc.condition_id = tsl.condition_id -- and any conditions on the target set level, if any
        LEFT JOIN dbo.syspolicy_policy_categories cat ON p.policy_category_id = cat.policy_category_id -- and the policy categories, if any
        WHERE fe.event_name=@event_type AND -- event type matches the fired event
            p.is_enabled = 1 AND -- policy is enabled
            fe.target_type_alias = @object_type AND -- target type matches the object in the event
            ts.enabled = 1 AND -- target set is enabled
            -- 1 means Enforce, 2 means CheckOnChange
            (p.execution_mode & @mode) = @mode AND -- policy mode matches the requested mode
            ((p.policy_category_id IS NULL) OR (cat.mandate_database_subscriptions = 1) OR ( ts.type_skeleton NOT LIKE 'Server/Database%') OR (@database IS NOT NULL AND pgs.target_object = @database)) AND
            ((@database IS NULL) OR 
             (@database IS NOT NULL AND 
              (tsl.condition_id IS NULL OR 
               (tsl.condition_id IS NOT NULL AND 
                ((lc.is_name_condition=1 AND @database = lc.obj_name) OR
                 (lc.is_name_condition=2 AND @database LIKE lc.obj_name) OR
                 (lc.is_name_condition=3 AND @database != lc.obj_name) OR
                 (lc.is_name_condition=4 AND @database NOT LIKE lc.obj_name))
               )
              )
             )
            ) 

    -- NOTE: if we haven't subscribed via an Endpoint facet on those events 
    -- we know for sure they will not be processed by the ServerAreaFacet policies 
    -- because syspolicy_facet_events expects @target_type to be SERVER
    -- so the filter will leave them out, and we are going to generate a fake 
    -- event to make those policies run
    IF( @synchronous = 0 AND 
        (@event_type IN ('ALTER_ENDPOINT', 'CREATE_ENDPOINT', 'DROP_ENDPOINT')))
    BEGIN
        DECLARE @fake_event_data xml
        SET @fake_event_data = CONVERT(xml, '<EVENT_INSTANCE><EventType>SAC_ENDPOINT_CHANGE</EventType><ObjectType>21075</ObjectType><ObjectName/><DatabaseName>master</DatabaseName></EVENT_INSTANCE>')
        
        EXEC [dbo].[sp_syspolicy_dispatch_event]  @event_data = @fake_event_data, @synchronous = 0
    END
            
END              

GO
