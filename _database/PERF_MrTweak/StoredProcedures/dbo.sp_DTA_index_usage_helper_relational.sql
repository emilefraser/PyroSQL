SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_index_usage_helper_relational]
	@SessionID		int,
	@IsRecommended	int
	as begin select D1.DatabaseName as "Database Name" ,T1.SchemaName as "Schema Name" ,T1.TableName as "Table/View Name" ,I1.IndexName as "Index Name" ,R.Count as "Number of references" ,CAST(R.Usage as decimal(38,2)) as "Percent Usage" from 
				DTA_reports_database as D1 ,
				DTA_reports_index as I1,
				DTA_reports_table as T1,
				(
					select D.DatabaseID,T.TableID ,
							I.IndexID  ,SUM(Q.Weight) as Count,
							100.0 *  SUM(Q.Weight) / 
							( 1.0 * (	select	CASE WHEN SUM(Q.Weight) > 0 THEN  SUM(Q.Weight)
												else 1
												end	
									
										from [MrTweak].[dbo].[DTA_reports_query] as Q
										where Q.SessionID = @SessionID ))
				as Usage
		from 
				[MrTweak].[dbo].[DTA_reports_index] as I	
				LEFT OUTER JOIN
				[MrTweak].[dbo].[DTA_reports_queryindex] as QI ON QI.IndexID = I.IndexID
				LEFT OUTER JOIN
				[MrTweak].[dbo].[DTA_reports_query] as Q ON QI.QueryID = Q.QueryID
				JOIN
				[MrTweak].[dbo].[DTA_reports_table] as T ON I.TableID = T.TableID
				JOIN
				[MrTweak].[dbo].[DTA_reports_database] as D ON T.DatabaseID = D.DatabaseID
				and Q.SessionID = QI.SessionID and 
				QI.IsRecommendedConfiguration = @IsRecommended and
				Q.SessionID = @SessionID
				
				GROUP BY I.IndexID,T.TableID,D.DatabaseID) as R
				where R.DatabaseID = D1.DatabaseID and
				R.TableID = T1.TableID and
				R.IndexID = I1.IndexID and
				D1.SessionID = @SessionID  and
				R.Count > 0
				order by R.Count desc end

GO
