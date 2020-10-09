SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_query_indexrelations_helper_xml] 
	@SessionID int ,
	@Recommended	int
as 
begin

	select 1            as Tag, 
			NULL          as Parent,
			'' as [StatementIndexReport!1!!ELEMENT],
			case when @Recommended = 1 then 'false'
			else'true' end
			as [StatementIndexReport!1!Current],	
			NULL as [StatementIndexDetail!2!stmtID!hide],
			NULL  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			NULL as [Database!3!DatabaseID!hide],
			NULL  as [Database!3!Name!ELEMENT] ,
			NULL  as [Schema!4!Name!ELEMENT] ,
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT],
			NULL as [Index!6!IndexID!hide],
			NULL as [Index!6!Name!ELEMENT]
	union all
	select 2            as Tag, 
			1          as Parent,
			NULL as [StatementIndexReport!1!!ELEMENT],
			NULL as [StatementIndexReport!1!Current],
			Q.QueryID as [StatementIndexDetail!2!stmtID!hide],
			Q.StatementString  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			NULL as [Database!3!DatabaseID!hide],
			NULL  as [Database!3!Name!ELEMENT] ,
			NULL  as [Schema!4!Name!ELEMENT] ,
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT],
			NULL as [Index!6!IndexID!hide],
			NULL as [Index!6!Name!ELEMENT]
			from [MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_query] Q,
			(	select Q.QueryID,D.DatabaseID
				from
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
				Q.SessionID=@SessionID
				group by Q.QueryID,D.DatabaseID) as R
				where
				R.QueryID = Q.QueryID and
				R.DatabaseID = D.DatabaseID and
				Q.SessionID = @SessionID
				and R.DatabaseID IS NOT NULL
	union all
	select 3            as Tag, 
			2          as Parent,
			NULL as [StatementIndexReport!1!!ELEMENT],
			NULL as [StatementIndexReport!1!Current],
			Q.QueryID as [StatementIndexDetail!2!stmtID!hide],
			Q.StatementString  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			D.DatabaseID as [Database!3!DatabaseID!hide],
			D.DatabaseName  as [Database!3!Name!ELEMENT] ,
			NULL  as [Schema!4!Name!ELEMENT] ,
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT],
			NULL as [Index!6!IndexID!hide],
			NULL as [Index!6!Name!ELEMENT]
			from [MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_query] Q,
			(	select Q.QueryID,D.DatabaseID
				from
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
				Q.SessionID=@SessionID
				group by Q.QueryID,D.DatabaseID) as R
				where
				R.QueryID = Q.QueryID and
				R.DatabaseID = D.DatabaseID and
				Q.SessionID = @SessionID
	union all
	select 4            as Tag, 
			3          as Parent,
			NULL as [StatementIndexReport!1!!ELEMENT],
			NULL as [StatementIndexReport!1!Current],
			Q.QueryID as [StatementIndexDetail!2!stmtID!hide],
			Q.StatementString  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			D.DatabaseID as [Database!3!DatabaseID!hide],
			D.DatabaseName  as [Database!3!Name!ELEMENT] ,
			R.SchemaName  as [Schema!4!Name!ELEMENT] ,
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT],
			NULL as [Index!6!IndexID!hide],
			NULL as [Index!6!Name!ELEMENT]
			from [MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_query] Q,
			(	select Q.QueryID,D.DatabaseID,T.SchemaName
				from
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
				Q.SessionID=@SessionID
				group by Q.QueryID,D.DatabaseID,T.SchemaName) as R
				where
				R.QueryID = Q.QueryID and
				R.DatabaseID = D.DatabaseID and
				Q.SessionID = @SessionID

	union all
	select 5            as Tag, 
			4          as Parent,
			NULL as [StatementIndexReport!1!!ELEMENT],
			NULL as [StatementIndexReport!1!Current],
			Q.QueryID as [StatementIndexDetail!2!stmtID!hide],
			Q.StatementString  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			D.DatabaseID as [Database!3!DatabaseID!hide],
			D.DatabaseName  as [Database!3!Name!ELEMENT] ,
			R.SchemaName  as [Schema!4!Name!ELEMENT] ,
			R.TableID as [Table!5!TableID!hide],
			T.TableName as [Table!5!Name!ELEMENT],
			NULL as [Index!6!IndexID!hide],
			NULL as [Index!6!Name!ELEMENT]
			from [MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_query] Q,
			[MrTweak].[dbo].[DTA_reports_table] T,
			(	select Q.QueryID,D.DatabaseID,T.SchemaName,T.TableID
				from
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
				Q.SessionID=@SessionID
				group by Q.QueryID,D.DatabaseID,T.SchemaName,T.TableID) as R
				where
				R.QueryID = Q.QueryID and
				R.DatabaseID = D.DatabaseID and
				Q.SessionID = @SessionID and
				R.TableID = T.TableID
	union all
	select 6            as Tag, 
			5          as Parent,
			NULL as [StatementIndexReport!1!!ELEMENT],
			NULL as [StatementIndexReport!1!Current],
			Q.QueryID as [StatementIndexDetail!2!stmtID!hide],
			Q.StatementString  as [StatementIndexDetail!2!StatementString!ELEMENT] ,
			D.DatabaseID as [Database!3!DatabaseID!hide],
			D.DatabaseName  as [Database!3!Name!ELEMENT] ,
			T.SchemaName  as [Schema!4!Name!ELEMENT] ,
			T.TableID as [Table!5!TableID!hide],
			T.TableName as [Table!5!Name!ELEMENT],
			I.IndexID as [Index!6!IndexID!hide],
			I.IndexName as [Index!6!Name!ELEMENT]
			from 		
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
				Q.SessionID=@SessionID
	order by [StatementIndexDetail!2!stmtID!hide],[Database!3!DatabaseID!hide],
			[Schema!4!Name!ELEMENT],[Table!5!TableID!hide],[Index!6!IndexID!hide]
	FOR XML EXPLICIT
end

GO
