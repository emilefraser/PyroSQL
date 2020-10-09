SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	create procedure [dbo].[sp_DTA_index_detail_recommended_helper_relational]
						@SessionID		int
						as
						begin	select "Database Name" = D.DatabaseName, "Schema Name" = T.SchemaName, "Table/View Name" = T.TableName, "Index Name" = I.IndexName, "Clustered" =	CASE
						WHEN I.IsClustered = 1 THEN 'Yes'	
						WHEN I.IsClustered = 0 THEN 'No'
						end, "Unique" =	CASE
						WHEN I.IsUnique = 1 THEN 'Yes'		
						WHEN I.IsUnique = 0 THEN 'No'
						end	, "Heap" =	CASE
						WHEN I.IsHeap = 1 THEN 'Yes'		
						WHEN I.IsHeap = 0 THEN 'No'
						end	, "Filtered" =	CASE
						WHEN I.IsFiltered = 1 THEN 'Yes'		
						WHEN I.IsFiltered = 0 THEN 'No'
						end	, "Index Size (MB)"= CAST(I.RecommendedStorage as decimal(38,2)) , "Number of Rows"= NumRows , "Filter Definition"= I.FilterDefinition 	from 
					DTA_reports_database  D,
					DTA_reports_table T,
					DTA_reports_index as I
					where
					D.SessionID = @SessionID and
					D.DatabaseID = T.DatabaseID and
					T.TableID = I.TableID and
					I.IsRecommended = 1  end 

GO
