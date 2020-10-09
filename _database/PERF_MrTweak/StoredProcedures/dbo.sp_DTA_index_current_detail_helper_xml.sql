SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_index_current_detail_helper_xml]
						@SessionID		int
as						
begin
select 1            as Tag, 
		NULL          as Parent,
		'' as [IndexDetailReport!1!!ELEMENT],
		'true' as [IndexDetailReport!1!Current],
		NULL as [Database!2!DatabaseID!hide],
		NULL  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!Clustered],
		NULL as [Index!5!Unique],
		NULL as [Index!5!Heap],
		NULL as [Index!5!FilteredIndex],
		NULL as [Index!5!IndexSizeInMB],
		NULL as [Index!5!NumberOfRows],
		NULL as [Index!5!FilterDefinition]
	union all
	select 2            as Tag, 
		1          as Parent,
		NULL as [IndexDetailReport!1!!ELEMENT],
		NULL as [IndexDetailReport!1!Recommended],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		NULL  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!Clustered],
		NULL as [Index!5!Unique],
		NULL as [Index!5!Heap],
		NULL as [Index!5!FilteredIndex],
		NULL as [Index!5!IndexSizeInMB],
		NULL as [Index!5!NumberOfRows],
		NULL as [Index!5!FilterDefinition]
	from [MrTweak].[dbo].[DTA_reports_database] as D
	where
	D.SessionID = @SessionID and
	D.DatabaseID in
	(select D.DatabaseID from
			[MrTweak].[dbo].[DTA_reports_table] as T,
			[MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_index] as I
			where
			D.SessionID = @SessionID and
			D.DatabaseID = T.DatabaseID and
			T.TableID = I.TableID and
			I.IsExisting = 1
			group by D.DatabaseID)
union all
	select 3            as Tag, 
		2          as Parent,
		NULL as [IndexDetailReport!1!!ELEMENT],
		NULL as [IndexDetailReport!1!Recommended],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		R.SchemaName  as [Schema!3!Name!ELEMENT] ,
		NULL as [Table!4!TableID!hide],
		NULL as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!Clustered],
		NULL as [Index!5!Unique],
		NULL as [Index!5!Heap],
		NULL as [Index!5!FilteredIndex],	
		NULL as [Index!5!IndexSizeInMB],
		NULL as [Index!5!NumberOfRows],
		NULL as [Index!5!FilterDefinition]
		from [MrTweak].[dbo].[DTA_reports_database] as D,
		(
			select D.DatabaseID,T.SchemaName 
			from
			[MrTweak].[dbo].[DTA_reports_table] as T,
			[MrTweak].[dbo].[DTA_reports_database] as D,
			[MrTweak].[dbo].[DTA_reports_index] as I
			where
			D.SessionID = @SessionID and
			D.DatabaseID = T.DatabaseID and
			T.TableID = I.TableID and
			I.IsExisting = 1
			group by D.DatabaseID,T.SchemaName
		) R
	where
	D.SessionID = @SessionID and
	D.DatabaseID = R.DatabaseID
union all
	select 4            as Tag, 
		3          as Parent,
		NULL as [IndexDetailReport!1!!ELEMENT],
		NULL as [IndexDetailReport!1!Recommended],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		R.SchemaName  as [Schema!3!Name!ELEMENT] ,
		R.TableID as [Table!4!TableID!hide],
		T.TableName  as [Table!4!Name!ELEMENT],
		NULL as [Index!5!IndexID!hide],
		NULL as [Index!5!Name!ELEMENT],
		NULL as [Index!5!Clustered],
		NULL as [Index!5!Unique],
		NULL as [Index!5!Heap],
		NULL as [Index!5!FilteredIndex],	
		NULL as [Index!5!IndexSizeInMB],
		NULL as [Index!5!NumberOfRows],
		NULL as [Index!5!FilterDefinition]
		from [MrTweak].[dbo].[DTA_reports_database] as D,
		 [MrTweak].[dbo].[DTA_reports_table] as T,
		(
			select D.DatabaseID,T.SchemaName,T.TableID
			from
				[MrTweak].[dbo].[DTA_reports_table] as T,
				[MrTweak].[dbo].[DTA_reports_database] as D,
				[MrTweak].[dbo].[DTA_reports_index] as I
			where
				D.SessionID = @SessionID and
				D.DatabaseID = T.DatabaseID and
				T.TableID = I.TableID and
				I.IsExisting = 1
			group by D.DatabaseID,T.SchemaName,T.TableID
		) R
		where
		D.SessionID = @SessionID and
		D.DatabaseID = R.DatabaseID and
		R.TableID = T.TableID and
		T.DatabaseID = D.DatabaseID
union all

	select 5            as Tag, 
		4          as Parent,
		NULL as [IndexDetailReport!1!!ELEMENT],
		NULL as [IndexDetailReport!1!Recommended],
		D.DatabaseID as [Database!2!DatabaseID!hide],
		D.DatabaseName  as [Database!2!Name!ELEMENT] ,
		T.SchemaName  as [Schema!3!Name!ELEMENT] ,
		T.TableID as [Table!4!TableID!hide],
		T.TableName  as [Table!4!Name!ELEMENT],
		I.IndexID as [Index!5!IndexID!hide],
		I.IndexName  as [Index!5!Name!ELEMENT],
		CASE
			WHEN I.IsClustered = 1 THEN 'true'	
			WHEN I.IsClustered = 0 THEN 'false'
		end
		as [Index!5!Clustered],
		CASE
			WHEN I.IsUnique = 1 THEN 'true'		
			WHEN I.IsUnique = 0 THEN 'false'
		end
		as [Index!5!Unique],	
		CASE
			WHEN I.IsHeap = 1 THEN 'true'		
			WHEN I.IsHeap = 0 THEN 'false'
		end
		as [Index!5!Heap],
		CASE
			WHEN I.IsFiltered = 1 THEN 'true'		
			WHEN I.IsFiltered = 0 THEN 'false'
		end
		as [Index!5!IsFiltered],				
		CAST(I.Storage as decimal(38,2)) as [Index!5!IndexSizeInMB],
		I.NumRows as [Index!5!NumberOfRows],
		I.FilterDefinition as [Index!5!FilterDefinition]
		from
		[MrTweak].[dbo].[DTA_reports_database]  D,
		[MrTweak].[dbo].[DTA_reports_table] T,
		[MrTweak].[dbo].[DTA_reports_index] as I
		where
		D.SessionID = @SessionID and
		D.DatabaseID = T.DatabaseID and
		T.TableID = I.TableID and
		I.IsExisting = 1
		order by [Database!2!DatabaseID!hide],[Schema!3!Name!ELEMENT],[Table!4!TableID!hide],[Index!5!IndexID!hide] 
	FOR XML EXPLICIT

end						

GO
