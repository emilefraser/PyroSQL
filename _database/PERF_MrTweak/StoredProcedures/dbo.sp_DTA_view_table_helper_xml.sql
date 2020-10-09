SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_view_table_helper_xml]
						@SessionID		int
as
begin
	select 1            as Tag, 
			NULL          as Parent,
			'' as [ViewTableReport!1!!ELEMENT],
			NULL as [Database!2!DatabaseID!hide],
			NULL  as [Database!2!Name!ELEMENT] ,
			NULL  as [Schema!3!Name!ELEMENT] ,
			NULL as [View!4!ViewID!hide],
			NULL as [View!4!Name!ELEMENT],
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT]
	union all
	select 2            as Tag, 
			1          as Parent,
			NULL as [ViewTableReport!1!!ELEMENT],
			D.DatabaseID as [Database!2!DatabaseID!hide],
			D.DatabaseName  as [Database!2!Name!ELEMENT] ,
			NULL  as [Schema!3!Name!ELEMENT] ,
			NULL as [View!4!ViewID!hide],
			NULL as [View!4!Name!ELEMENT],
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT]
			from	[MrTweak].[dbo].[DTA_reports_database] as D
			where
				D.SessionID = @SessionID and
				D.DatabaseID in 
				(
					select D.DatabaseID
					from [MrTweak].[dbo].[DTA_reports_table] as T,
						[MrTweak].[dbo].[DTA_reports_database] as D
						where
						T.IsView = 1 and
						T.DatabaseID = D.DatabaseID and
						D.SessionID = @SessionID
						GROUP BY D.DatabaseID)
	union all
	select 3            as Tag, 
			2          as Parent,
			NULL as [ViewTableReport!1!!ELEMENT],
			D.DatabaseID as [Database!2!DatabaseID!hide],
			D.DatabaseName  as [Database!2!Name!ELEMENT] ,
			R.SchemaName  as [Schema!3!Name!ELEMENT] ,
			NULL as [View!4!ViewID!hide],
			NULL as [View!4!Name!ELEMENT],
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT]
			from	[MrTweak].[dbo].[DTA_reports_database] as D,
					(select D.DatabaseID,T.SchemaName
							from [MrTweak].[dbo].[DTA_reports_table] as T,
							[MrTweak].[dbo].[DTA_reports_database] as D
							where
							T.IsView = 1 and
							T.DatabaseID = D.DatabaseID and
							D.SessionID = @SessionID
							GROUP BY D.DatabaseID,T.SchemaName
					) R
			where
				R.DatabaseID = D.DatabaseID and
				D.SessionID = @SessionID

	union all
	select 4            as Tag, 
			3          as Parent,
			NULL as [ViewTableReport!1!!ELEMENT],
			D.DatabaseID as [Database!2!DatabaseID!hide],
			D.DatabaseName  as [Database!2!Name!ELEMENT] ,
			R.SchemaName  as [Schema!3!Name!ELEMENT] ,
			T.TableID as [View!4!ViewID!hide],
			T.TableName as [View!4!Name!ELEMENT],
			NULL as [Table!5!TableID!hide],
			NULL as [Table!5!Name!ELEMENT]
			from	[MrTweak].[dbo].[DTA_reports_table] as T,
					[MrTweak].[dbo].[DTA_reports_database] as D,
					(select D.DatabaseID,T.SchemaName,T.TableID
							from [MrTweak].[dbo].[DTA_reports_table] as T,
							[MrTweak].[dbo].[DTA_reports_database] as D
							where
							T.IsView = 1 and
							T.DatabaseID = D.DatabaseID and
							D.SessionID = @SessionID
							GROUP BY D.DatabaseID,T.SchemaName,T.TableID
					) R
			where
				R.DatabaseID = D.DatabaseID and
				T.TableID = R.TableID and
				D.SessionID = @SessionID
	union all
	select 5            as Tag, 
			4          as Parent,
			NULL as [ViewTableReport!1!!ELEMENT],
			D.DatabaseID as [Database!2!DatabaseID!hide],
			D.DatabaseName  as [Database!2!Name!ELEMENT] ,
			T2.SchemaName  as [Schema!3!Name!ELEMENT] ,
			T2.TableID as [View!4!ViewID!hide],
			T2.TableName as [View!4!Name!ELEMENT],
			T1.TableID as [Table!5!TableID!hide],
			T1.TableName as [Table!5!Name!ELEMENT]
			from
			[MrTweak].[dbo].[DTA_reports_database] D, 
			[MrTweak].[dbo].[DTA_reports_tableview] TV, 
			[MrTweak].[dbo].[DTA_reports_table] T1,
			[MrTweak].[dbo].[DTA_reports_table] T2
		where 
			D.DatabaseID=T1.DatabaseID and 
			D.DatabaseID=T2.DatabaseID and
			T1.TableID=TV.TableID and 
			T2.TableID=TV.ViewID and
			D.SessionID = @SessionID

	order by [Database!2!DatabaseID!hide],[Schema!3!Name!ELEMENT],[View!4!ViewID!hide],[Table!5!TableID!hide]
	FOR XML EXPLICIT
end						

GO
