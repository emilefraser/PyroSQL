SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 create procedure [dbo].[sp_DTA_table_access_helper_relational]
			@SessionID		int
			as
			begin select D1.DatabaseName as "Database Name" ,T1.SchemaName as "Schema Name" ,T1.TableName as "Table Name" ,R.Count as "Number of references" ,CAST(R.Usage as decimal(38,2)) as "Percent Usage" from 
				[MrTweak].[dbo].[DTA_reports_database] as D1 ,
				[MrTweak].[dbo].[DTA_reports_table] as T1,
				(
					select D.DatabaseID,T.TableID 
							,SUM(Q.Weight) as Count,
							100.0 *  SUM(Q.Weight) / 
							( 1.0 * (	select	CASE WHEN SUM(Q.Weight) > 0 THEN  SUM(Q.Weight)
												else 1
												end	
									
										from [MrTweak].[dbo].[DTA_reports_query] as Q
										where Q.SessionID = @SessionID ))
				as Usage
		from 
				[MrTweak].[dbo].[DTA_reports_table] as T
				LEFT OUTER JOIN
				[MrTweak].[dbo].[DTA_reports_querytable] as QT ON QT.TableID = T.TableID
				LEFT OUTER JOIN
				[MrTweak].[dbo].[DTA_reports_query] as Q ON QT.QueryID = Q.QueryID
				JOIN
				DTA_reports_database as D ON T.DatabaseID = D.DatabaseID
				and Q.SessionID = QT.SessionID and 
				Q.SessionID = @SessionID		
				GROUP BY T.TableID,D.DatabaseID) as R
				where R.DatabaseID = D1.DatabaseID and
				R.TableID = T1.TableID and
				D1.SessionID = @SessionID and
				R.Count > 0
				order by R.Count desc  end 

GO
