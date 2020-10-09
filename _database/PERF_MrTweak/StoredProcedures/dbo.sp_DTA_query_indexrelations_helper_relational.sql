SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	create procedure [dbo].[sp_DTA_query_indexrelations_helper_relational]
							@SessionID		int,
							@Recommended	int
							as
							begin 	select "Statement Id" =Q.QueryID, "Statement String" =Q.StatementString,"Database Name" =D.DatabaseName, "Schema Name" =T.SchemaName, "Table/View Name" =T.TableName, "Index Name" =I.IndexName 	 from 
						[MrTweak].[dbo].[DTA_reports_query] Q, 
						[MrTweak].[dbo].[DTA_reports_queryindex] QI, 
						[MrTweak].[dbo].[DTA_reports_index] I, 
						[MrTweak].[dbo].[DTA_reports_table] T,
						[MrTweak].[dbo].[DTA_reports_database] D
						where 
						Q.SessionID=QI.SessionID and 
						Q.QueryID=QI.QueryID and 
						QI.IndexID=I.IndexID and 
						I.TableID=T.TableID and 
						T.DatabaseID = D.DatabaseID and
						QI.IsRecommendedConfiguration = @Recommended and
						Q.SessionID=@SessionID order by Q.QueryID  end 

GO
