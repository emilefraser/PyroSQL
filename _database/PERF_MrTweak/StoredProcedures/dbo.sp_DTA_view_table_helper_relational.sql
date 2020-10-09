SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	create procedure [dbo].[sp_DTA_view_table_helper_relational]
						@SessionID		int
						as
						begin  select "View Id" =T2.TableID, "Database Name" =D.DatabaseName, "Schema Name" =T2.SchemaName, "View Name" =T2.TableName, "Database Name" =D.DatabaseName, "Schema Name" =T1.SchemaName, "Table Name" =T1.TableName 	from 
					[MrTweak].[dbo].[DTA_reports_database] D, 
					[MrTweak].[dbo].[DTA_reports_tableview] TV, 
					[MrTweak].[dbo].[DTA_reports_table] T1,
					[MrTweak].[dbo].[DTA_reports_table] T2
					where 
						D.DatabaseID=T1.DatabaseID and 
						D.DatabaseID=T2.DatabaseID and
						T1.TableID=TV.TableID and 
						T2.TableID=TV.ViewID and
						D.SessionID=@SessionID
						order by TV.ViewID  end 

GO
