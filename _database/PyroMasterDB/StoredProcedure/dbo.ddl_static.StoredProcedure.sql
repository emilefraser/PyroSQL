SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ddl_static]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ddl_static] AS' 
END
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB part of ddl generation process ( when making new betl release) . create static data ddl. 
*/    
ALTER   PROCEDURE [dbo].[ddl_static] as 
begin 
set nocount on 
print '
-- begin ddl_content
set nocount on 
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (0, N''unknown'', NULL)
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (100, N''success'', N''Execution of batch or transfer finished without any errors. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (200, N''error'', N''Execution of batch or transfer raised an error.'')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (300, N''not started'', N''Execution of batch or transfer is not started because it cannot start (maybe it''''s already running). '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (400, N''running'', N''Batch or transfer is running. do not start a new instance.'')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (600, N''continue'', N''This batch is continuing where the last instance stopped. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (700, N''stopped'', N''batch stopped without error (can be continued any time). '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (800, N''skipped'', N''Transfer is skipped because batch will continue where it has left off. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (900, N''deleted'', N''Transfer or batch is deleted / dropped'')
GO
'
print '
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N''unknown'', N''Unknown,  not relevant'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N''nat_pkey'', N''Natural primary key (e.g. user_key)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N''nat_fkey'', N''Natural foreign key (e.g. create_user_key)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N''sur_pkey'', N''Surrogate primary key (e.g. user_id)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N''sur_fkey'', N''Surrogate foreign key (e.g. create_user_id)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N''attribute'', N''low or non repetetive value for containing object. E.g. customer lastname, firstname.'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N''meta data'', NULL, CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''navision'', 1)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''exact'', 2)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''adp'', 2)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (10, N''table'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (20, N''view'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (30, N''schema'', 30)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (40, N''database'', 20)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (50, N''server'', 10)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (60, N''user'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (70, N''procedure'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (80, N''role'', 30)
GO
'
print'
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgd'', 12)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgf'', 13)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgh'', 8)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgl'', 10)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N''target_schema_id'', N''used for deriving target table'', N''db_object'', NULL, 1, 1, 1, 1, NULL, NULL, CAST(N''2015-08-31T13:18:22.073'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (15, N''template_id'', N''which ETL template to use (see def.Template) '', N''db_object'', NULL, 0, 0, 1, 1, NULL, NULL, CAST(N''2017-09-07T09:12:49.160'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N''has_synonym_id'', N''apply syn pattern (see biblog.nl)'', N''db_object'', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N''2015-08-31T13:18:56.070'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N''has_record_dt'', N''add this column (insert date time) to all tables'', N''db_object'', NULL, 0, 0, 0, 0, 1, NULL, CAST(N''2015-08-31T13:19:09.607'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N''has_record_user'', N''add this column (insert username ) to all tables'', N''db_object'', NULL, 0, 0, 1, 0, 1, NULL, CAST(N''2015-08-31T13:19:15.000'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N''is_linked_server'', N''Should a server be accessed like a linked server (e.g. via openquery). Used for SSAS servers.'', N''db_object'', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-08-31T17:17:37.830'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N''date_datatype_based_on_suffix'', N''if a column ends with the suffix _date then it''''s a date datatype column (instead of e.g. datetime)'', N''db_object'', N''1'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-02T13:16:15.733'' AS DateTime), N''My_PC\BAS'')
GO
'
print '
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N''is_localhost'', N''This server is localhost. For performance reasons we don''''t want to access localhost via linked server as we would with external sources'', N''db_object'', N''0'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-24T16:22:45.233'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N''recreate_tables'', N''This will drop and create tables (usefull during initial development)'', N''db_object'', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N''prefix_length'', N''This object name uses a prefix of certain length x. Strip this from target name. '', N''db_object'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N''etl_meta_fields'', N''etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source'', N''db_object'', N''1'', NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (120, N''exec_sql'', N''set this to 0 to print the generated sql instead of executing it. usefull for debugging'', N''user'', N''1'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:04:49.867'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (130, N''log_level'', N''controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE'', N''user'', N''INFO'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:06:12.167'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (140, N''nesting'', N''used by dbo.log in combination with log_level  to determine wheter or not to print a message'', N''user'', N''0'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:08:02.967'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (150, N''delete_detection'', N''detect deleted records'', N''db_object'', N''1'', 1, 1, 1, NULL, NULL, NULL, CAST(N''2017-12-19T14:08:52.533'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (160, N''use_key_domain'', N''adds key_domain_id to natural primary key of hubs to make key unique for a particular domain. push can derive key_domain e.g.  from source system name'', N''db_object'', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-01-09T10:26:57.017'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (170, N''privacy_level'', N''scale : normal, sensitive, personal'', N''db_object'', N''10'', 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-04-09T16:38:43.057'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (180, N''filter_delete_detection'', N''custom filter for delete detection'', N''db_object'', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-07-04T17:27:29.857'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (190, N''proc_max_cnt'', N''how many concurrent processes / jobs. default 4 '', N''user'', N''4'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-23T17:20:03.690'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (200, N''proc_max_wait_time_min'', N''how long should we wait for a proc to finish when proc_max_cnt is reached. default 10 minutes. please increase this value for big datasets!'', N''user'', N''10'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:27:24.543'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (210, N''proc_polling_interval_sec'', N''wait polling interval. How long till we check again. range: 1-59 . Too low might affect performance because every time we query  msdb.dbo.sysjobs'', N''user'', N''2'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:29:17.060'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
'
print '
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (220, N''proc_dead_time_sec'', N''delete jobs that are created more than @proc_dead_time_sec ago and are not running. '', N''user'', N''60'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:40:13.197'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (1, N''truncate_insert'', N''truncate_insert'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (2, N''drop_insert'', N''drop_insert'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (3, N''delta_insert_first_seq'', N''delta insert based on a first sequential ascending column'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (4, N''truncate_insert_create_stgh'', N''truncate_insert imp_table then create stgh view lowercase, nvarchar->varchar, money->decimal '', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (5, N''create_stgh'', N''create stgh view (follow up on template 4)'', CAST(N''2018-05-30 11:03:13.127'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (6, N''switch'', N''transfer to switching tables (Datamart)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (7, N''delta_insert_eff_dt'', N''delta insert based on eff_dt column'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (8, N''hub_and_sat'', N''Datavault Hub & Sat (CDC and delete detection)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (9, N''hub_sat'', N''Datavault Hub Sat (part of transfer_method 8)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (10, N''link_and_sat'', N''Datavault Link & Sat (CDC and delete detection)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (11, N''link_sat'', N''Datavault Link Sat (part of transfer_method 10)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (12, N''dim'', N''Kimball Dimension'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (13, N''fact'', N''Kimball Fact'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (14, N''fact_append'', N''Kimball Fact Append'', NULL, NULL)
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (10, N''ERROR'', N''Only log errors'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (20, N''WARN'', N''Log errors and warnings (SSIS mode)'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (30, N''INFO'', N''Log headers and footers'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (40, N''DEBUG'', N''Log everything only at top nesting level'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (50, N''VERBOSE'', N''Log everything all nesting levels'')
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (10, N''Header'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (20, N''Footer'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (30, N''SQL'', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (40, N''VAR'', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (50, N''Error'', 10)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (60, N''Warn'', 20)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (70, N''Step'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (80, N''Progress'', 50)
GO

'
print '
set identity_insert dbo.Batch on 
GO
insert into dbo.Batch(batch_id, batch_name) values ( -1, ''Unknown'')
GO
set identity_insert dbo.Batch off
GO
set identity_insert dbo.Transfer on 
GO
insert into dbo.Transfer(transfer_id, transfer_name) values ( -1, ''Unknown'')
GO
set identity_insert dbo.Transfer off
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (10, N''sql server'', N''SQL Server 2012 (SP3) (KB3072779) - 11.0.6020.0 (X64)'')
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (20, N''ssas tabular'', N''SQL Server Analysis Services Tabular Databases with Compatibility Level 1200'')
GO
insert into dbo.Obj(obj_type_id, obj_name)
values ( 50, ''LOCALHOST'')
GO
exec dbo.setp ''is_localhost'', 1 , ''LOCALHOST''
'
print '-- end of ddl_content'
end













GO
