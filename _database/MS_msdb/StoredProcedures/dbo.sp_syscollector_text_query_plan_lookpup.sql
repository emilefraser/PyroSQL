SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_text_query_plan_lookpup]
    @plan_handle varbinary(64),
    @statement_start_offset int,
    @statement_end_offset int
AS
BEGIN
    SET NOCOUNT ON
    SELECT    
        @plan_handle AS plan_handle,
        @statement_start_offset AS statement_start_offset,
        @statement_end_offset AS statement_end_offset,
        [dbid] AS database_id,
        [objectid] AS object_id,
        OBJECT_NAME(objectid, dbid) AS object_name,
        [query_plan] AS query_plan
    FROM    
        [sys].[dm_exec_text_query_plan](@plan_handle, @statement_start_offset, @statement_end_offset) dm
END

GO
