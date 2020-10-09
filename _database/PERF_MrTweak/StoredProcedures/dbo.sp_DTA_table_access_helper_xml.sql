SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_table_access_helper_xml]
			@SessionID		int
as
begin
select 1            as Tag, 
		NULL          as Parent,
		'' as [TableAccessReport!1!!ELEMENT],
		NULL as [Database!2!DatabaseID!hide],
		NULL  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Table!4!NumberOfReferences!ELEMENT],
		NULL as [Table!4!PercentUsage!ELEMENT]
	union all
	select 
		2            as Tag, 
		1          as Parent,
		NULL as [TableAccessReport!1!!ELEMENT],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Table!4!NumberOfReferences!ELEMENT],
		NULL as [Table!4!PercentUsage!ELEMENT]
	from [MrTweak].[dbo].[DTA_reports_database] as D
	where
	D.SessionID = @SessionID and
	D.DatabaseID in
	(select D.DatabaseID from
			[MrTweak].[dbo].[DTA_reports_querytable] as QT,
			[MrTweak].[dbo].[DTA_reports_table] as T,
			[MrTweak].[dbo].[DTA_reports_database] as D
			where
			QT.TableID = T.TableID  and
			T.DatabaseID = D.DatabaseID and
			D.SessionID = @SessionID
			group by D.DatabaseID)
	

union all

	select 3 as Tag, 2 as Parent, 
		NULL as [TableAccessReport!1!!ELEMENT],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		R.SchemaName  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Table!4!NumberOfReferences!ELEMENT],
		NULL as [Table!4!PercentUsage!ELEMENT]

	from [MrTweak].[dbo].[DTA_reports_database] as D,
	(
		select D.DatabaseID,T.SchemaName from
		[MrTweak].[dbo].[DTA_reports_querytable] as QT,
		[MrTweak].[dbo].[DTA_reports_table] as T,
		[MrTweak].[dbo].[DTA_reports_database] as D
		where
		QT.TableID = T.TableID  and
		T.DatabaseID = D.DatabaseID and
		D.SessionID = @SessionID
		group by D.DatabaseID,T.SchemaName
) R

	where
	D.SessionID = @SessionID and
	D.DatabaseID = R.DatabaseID
	union all
	
	select 4 as Tag, 3 as Parent,

		NULL as [TableAccessReport!1!!ELEMENT],
		D1.DatabaseID as [Database!2!DatabaseID!hide],
		D1.DatabaseName  as [Database!2!Name!ELEMENT] ,
		T1.SchemaName  as [Schema!3!Name!ELEMENT] ,
		T1.TableID as [Table!4!TableID!hide],
		T1.TableName as [Table!4!Name!ELEMENT],
		R.Count as [Table!4!NumberOfReferences!ELEMENT],
		CAST(R.Usage as decimal(38,2)) as [Table!4!PercentUsage!ELEMENT]

from 
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
				[MrTweak].[dbo].[DTA_reports_database] as D ON T.DatabaseID = D.DatabaseID
				and Q.SessionID = QT.SessionID and 
				Q.SessionID = @SessionID		
				GROUP BY T.TableID,D.DatabaseID) as R
				where R.DatabaseID = D1.DatabaseID and
				R.TableID = T1.TableID and
				D1.SessionID = @SessionID and
				R.Count > 0

	order by [Database!2!DatabaseID!hide],[Schema!3!Name!ELEMENT],[Table!4!TableID!hide],[Table!4!NumberOfReferences!ELEMENT] 

	FOR XML EXPLICIT
end

GO
