SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_initialize_mdw]
   @mdw_database_name   SYSNAME, 
   @require_mdw         BIT = 1, 
   @force_stub_use      BIT = 0, 
   @refresh_views       BIT = 1
WITH EXECUTE AS OWNER
AS
BEGIN

   -- Check if @mdw_database_name is NULL or empty
   IF (@mdw_database_name IS NULL OR @mdw_database_name = N'')
   BEGIN
       RAISERROR(14043, -1, -1, 'mdw_database_name', 'sp_sysutility_ucp_initialize_mdw')
       RETURN(1)
   END


   IF (@require_mdw = 1) AND NOT EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE name = @mdw_database_name)
   BEGIN
        RAISERROR(37002, -1, -1, @mdw_database_name)
        RETURN(1)
   END

   DECLARE @database sysname;
   DECLARE @schema sysname;
   DECLARE @is_ucp bit;

   -- If the sysutility_mdw database has been installed and the instance appears to be a UCP, we should 
   -- point the synonyms at the MDW objects.  Otherwise, the synonyms should reference the stub objects 
   -- (with a "_stub" suffix) that we just created.  Note that during UCP creation, this proc is called 
   -- at an interim step before fn_sysutility_get_is_instance_ucp returns 1.  However, @require_mdw will 
   -- be set to 1 in this case, telling us that we should redirect the synonyms to the MDW db even though . 
   -- the instance is not (yet) completely set up as a UCP. 
   IF (DB_ID (@mdw_database_name) IS NOT NULL) 
      AND ((@require_mdw = 1) OR (dbo.fn_sysutility_get_is_instance_ucp() = 1))
      AND (@force_stub_use = 0)
   BEGIN
       -- This instance is a UCP; synonyms should reference objects in sysutility_mdw
       SET @database = @mdw_database_name;
       SET @schema = 'sysutility_ucp_core';
      
       -- Dimensions
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_computers', @database, @schema, 'latest_computers';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_volumes', @database, @schema, 'latest_volumes';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_dacs', @database, @schema, 'latest_dacs';	   
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_smo_servers', @database, @schema, 'latest_smo_servers';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_databases', @database, @schema, 'latest_databases';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_filegroups', @database, @schema, 'latest_filegroups';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_datafiles', @database, @schema, 'latest_datafiles';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_logfiles', @database, @schema, 'latest_logfiles';

       -- Measures
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_cpu_utilization', @database, @schema, 'cpu_utilization';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_space_utilization', @database, @schema, 'space_utilization';

      -- Now that msdb is set up, call a setup proc in MDW to do any runtime initialization that is 
      -- needed in that database.  Only exec the proc if it exists -- it won't exist yet when instmsdb.sql 
      -- is run on upgrade from CTP3 to RTM, because the MDW initialization proc was added post-CTP3 and 
      -- upgrade executes instmsdb.sql prior to instmdw.sql.  This proc will be re-executed by the post-upgrade 
      -- script post_upgrade_ucp_cmdw.sql, and at that time the MDW proc will have been created. 
      DECLARE @sql nvarchar(max);
      DECLARE @mdw_proc_name nvarchar(max);
      SET @mdw_proc_name = QUOTENAME(@mdw_database_name) + '.sysutility_ucp_core.sp_initialize_mdw_internal';
      SET @sql = 'EXEC ' + @mdw_proc_name;
      IF OBJECT_ID (@mdw_proc_name) IS NOT NULL 
      BEGIN
         RAISERROR ('Executing %s', 0, 1, @mdw_proc_name) WITH NOWAIT;
         EXEC (@sql);
      END
      ELSE BEGIN
         RAISERROR ('Skipping execution of %s', 0, 1, @mdw_proc_name) WITH NOWAIT;
      END;
                 
   END
   ELSE BEGIN
       -- This instance is not a UCP; synonyms should reference msdb stub objects
       SET @database = 'msdb';
       SET @schema = 'dbo';
               
       -- Dimensions
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_computers', @database, @schema, 'sysutility_ucp_computers_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_volumes', @database, @schema, 'sysutility_ucp_volumes_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_dacs', @database, @schema, 'sysutility_ucp_dacs_stub';
       
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_smo_servers', @database, @schema, 'sysutility_ucp_smo_servers_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_databases', @database, @schema, 'sysutility_ucp_databases_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_filegroups', @database, @schema, 'sysutility_ucp_filegroups_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_datafiles', @database, @schema, 'sysutility_ucp_datafiles_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_logfiles', @database, @schema, 'sysutility_ucp_logfiles_stub';
       
       -- Measures
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_cpu_utilization', @database, @schema, 'sysutility_ucp_cpu_utilization_stub';
       EXEC dbo.sp_sysutility_ucp_recreate_synonym_internal N'syn_sysutility_ucp_space_utilization', @database, @schema, 'sysutility_ucp_space_utilization_stub';		   
                   
   END;

   IF (@refresh_views = 1)
   BEGIN
       -- Refresh the msdb wrapper views to ensure that the view metadata matches the underlying table metadata. 
       -- This is necessary for two reasons: 
       --  a) When this procecure is executed by the Create UCP process, it may change the structure of the tables 
       --     that the msdb wrapper views reference, by redirecting the synonyms from the msdb stub tables to 
       --     different tables in MDW.  The refresh ensures that the view metadata matches that of the new 
       --     referenced tables. 
       --  b) The proc is also executed after msdb and MDW schema upgrade.  In this case, the MDW upgrade may have 
       --     changed the MDW table schema even if the synonyms weren't redirected.  
       RAISERROR ('Refreshing msdb wrapper views', 0, 1) WITH NOWAIT;
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_computers';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_volumes';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_instances';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_databases';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_filegroups';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_datafiles';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_logfiles';
       EXEC dbo.sp_refreshview N'dbo.sysutility_ucp_utility_space_utilization';
   END;
END;

GO
