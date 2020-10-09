SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 create procedure [dbo].[sp_DTA_column_access_helper_relational]
			@SessionID		int
			as
			begin select D1.DatabaseName as "Database Name" ,T1.SchemaName as "Schema Name" ,T1.TableName as "Table/View Name" ,C1.ColumnName as "Column Name" ,R.Count as "Number of references" ,CAST(R.Usage as decimal(38,2)) as "Percent Usage" from 
				[MrTweak].[dbo].[DTA_reports_database] as D1 ,
				[MrTweak].[dbo].[DTA_reports_table] as T1,
				[MrTweak].[dbo].[DTA_reports_column] as C1,
			
				(
					select D.DatabaseID,T.TableID,C.ColumnID,
							SUM(Q.Weight) as Count,
							100.0 *  SUM(Q.Weight) / 
							( 1.0 * (	select	CASE WHEN SUM(Q.Weight) > 0 THEN  SUM(Q.Weight)
												else 1
												end	
									
										from [MrTweak].[dbo].[DTA_reports_query] as Q
										where Q.SessionID = @SessionID ))
				as Usage
		from 
				[MrTweak].[dbo].[DTA_reports_column] as C
				LEFT OUTER JOIN
				DTA_reports_querycolumn as QC ON QC.ColumnID = C.ColumnID
				LEFT OUTER JOIN
				DTA_reports_query as Q ON QC.QueryID = Q.QueryID
				JOIN
				DTA_reports_table as T ON C.TableID = T.TableID
				JOIN
				DTA_reports_database as D ON T.DatabaseID = D.DatabaseID
				and Q.SessionID = QC.SessionID and 
				Q.SessionID = @SessionID		
				GROUP BY C.ColumnID,T.TableID,D.DatabaseID) as R
				where R.DatabaseID = D1.DatabaseID and
				R.TableID = T1.TableID and
				R.ColumnID = C1.ColumnID and
				D1.SessionID = @SessionID and
				R.Count > 0
				order by R.Count desc end 

GO
