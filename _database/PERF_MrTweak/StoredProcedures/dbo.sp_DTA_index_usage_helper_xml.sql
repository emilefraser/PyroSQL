SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_index_usage_helper_xml]
	@SessionID		int,
	@IsRecommended	int
as	
begin
select 1            as Tag, 
		NULL          as Parent,
		'' as [IndexUsageReport!1!!ELEMENT],
		case when @IsRecommended = 1 then 'false'
		else 'true' end as [IndexUsageReport!1!Current],
		NULL as [Database!2!DatabaseID!hide],
		NULL  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!NumberOfReferences!ELEMENT],
		NULL as [Index!5!PercentUsage!ELEMENT]
	union all
select 2            as Tag, 
		1          as Parent,
		NULL as [IndexUsageReport!1!!ELEMENT],
		NULL as [IndexUsageReport!1!Current],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!NumberOfReferences!ELEMENT],
		NULL as [Index!5!PercentUsage!ELEMENT]
	from [MrTweak].[dbo].[DTA_reports_database] as D
	where
	D.SessionID = @SessionID and
	D.DatabaseID in
	(select D.DatabaseID from
			[MrTweak].[dbo].[DTA_reports_queryindex] as QI,
			[MrTweak].[dbo].[DTA_reports_index] as I,
			[MrTweak].[dbo].[DTA_reports_table] as T,
			[MrTweak].[dbo].[DTA_reports_database] as D
			where
			QI.IndexID = I.IndexID  and
			I.TableID = T.TableID and
			T.DatabaseID = D.DatabaseID and
			D.SessionID = @SessionID and
			QI.IsRecommendedConfiguration = @IsRecommended
			GROUP BY D.DatabaseID)
	union all
select 3            as Tag, 
		2          as Parent,
		NULL as [IndexUsageReport!1!!ELEMENT],
		NULL as [IndexUsageReport!1!Current],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		R.SchemaName  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!NumberOfReferences!ELEMENT],
		NULL as [Index!5!PercentUsage!ELEMENT]
	from [MrTweak].[dbo].[DTA_reports_database] as D,
	(
		select D.DatabaseID,T.SchemaName from
		[MrTweak].[dbo].[DTA_reports_queryindex] as QI,
		[MrTweak].[dbo].[DTA_reports_index] as I,
		[MrTweak].[dbo].[DTA_reports_table] as T,
		[MrTweak].[dbo].[DTA_reports_database] as D
		where
		QI.IndexID = I.IndexID  and
		I.TableID = T.TableID and
		T.DatabaseID = D.DatabaseID and
		QI.IsRecommendedConfiguration = @IsRecommended and
		D.SessionID = @SessionID
		GROUP BY D.DatabaseID,T.SchemaName
	) R
	where
	D.SessionID = @SessionID and
	D.DatabaseID = R.DatabaseID
union all

select 4            as Tag, 
		3          as Parent,
		NULL as [IndexUsageReport!1!!ELEMENT],
		NULL as [IndexUsageReport!1!Current],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName as [Database!2!Name!ELEMENT] ,
		R.SchemaName  as [Schema!3!Name!ELEMENT] ,
		R.TableID as [Table!4!TableID!hide],
		T.TableName as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!NumberOfReferences!ELEMENT],
		NULL as [Index!5!PercentUsage!ELEMENT]

	from	 [MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_table] as T,
	(
		select D.DatabaseID,T.SchemaName,T.TableID from
		[MrTweak].[dbo].[DTA_reports_queryindex] as QI,
		[MrTweak].[dbo].[DTA_reports_index] as I,
		[MrTweak].[dbo].[DTA_reports_table] as T,
		[MrTweak].[dbo].[DTA_reports_database] as D
		where
		QI.IndexID = I.IndexID  and
		I.TableID = T.TableID and
		T.DatabaseID = D.DatabaseID and
		D.SessionID = @SessionID and
		QI.IsRecommendedConfiguration = @IsRecommended
		GROUP BY D.DatabaseID,T.SchemaName, T.TableID
	) R
	where
	D.SessionID = @SessionID and
	D.DatabaseID = R.DatabaseID and
	R.TableID = T.TableID and
	T.DatabaseID = D.DatabaseID

union all
select 5            as Tag, 
		4          as Parent,
		NULL as [IndexUsageReport!1!!ELEMENT],
		NULL as [IndexUsageReport!1!Current],
		D1.DatabaseID as [Database!2!DatabaseID!hide],
		D1.DatabaseName as [Database!2!Name!ELEMENT] ,
		T1.SchemaName  as [Schema!3!Name!ELEMENT] ,
		T1.TableID as [Table!4!TableID!hide],
		T1.TableName as [Table!4!Name!ELEMENT],
		I1.IndexID as [Index!5!IndexID!hide],
		I1.IndexName as [Index!5!Name!ELEMENT],
		R.Count as [Index!5!NumberOfReferences!ELEMENT],
		CAST(R.Usage as decimal(38,2))  as [Index!5!PercentUsage!ELEMENT]
		from
			[MrTweak].[dbo].[DTA_reports_database] as D1 ,
			[MrTweak].[dbo].[DTA_reports_index] as I1,
			[MrTweak].[dbo].[DTA_reports_table] as T1,
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
	order by [Database!2!DatabaseID!hide],[Schema!3!Name!ELEMENT],[Table!4!TableID!hide],
			[Index!5!NumberOfReferences!ELEMENT] , [Index!5!IndexID!hide] 

	FOR XML EXPLICIT
end	

GO
