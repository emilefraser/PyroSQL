SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DC].[vw_mat_Field] AS
SELECT 
FieldID AS [Field ID],
FieldName AS [Field Name],
DataType AS [Data Type],
[MaxLength] AS [Max Length],
[Precision] AS [Precision],
[Scale] AS [Scale],
StringLength AS [String Length],
[Description] AS [Description],
IsPrimaryKey AS [Is Primary Key],
IsForeignKey AS [Is Foreign Key],
DefaultValue AS [Default Value],
SystemGenerated AS [System Generated],
DataQualityScore AS [Data Quality Score],
dpNullCount AS [dp Null Count],
dpNullCountPerc AS [dp Null Count Perc],
dpDistinctCount AS [dp Distinct Count],
dpDuplicateCount AS [dp Duplicate Count],
dpDuplicatCountPerc AS [dp Duplicate Count Perc],
dpOrphanedChildrenCount AS [dp Orphaned Children Count],
dpOrphanedChildrenCountPerc AS [dp Orphaned Children Count Perc],
dpMinimum AS [dp Minimum],
dpMaximum AS [dp Maximum],
[dpAverage] AS [dp Average],
[dpMedian] AS [dp Median],
[dpStandardDeviation] AS [dp Standard Deviation],
[DataEntityID] AS [DataEntity ID],
[SystemEntityID] AS [SystemEntity ID],
[IsSystemEntityDefinedAtRecordLevel] AS [Is System Entity Defined At Record Level],
[DQScore] AS [DQ Score],
[DBColumnID] AS [Database Column ID],
[CreatedDT] AS [Created Date],
UpdatedDT AS [Updated Date],
[DataEntitySize] AS [Data Entity Size],
[DatabaseSize] AS [Database Size],
[IsActive] AS [Is Active],
[FieldSortOrder] AS [Field Sort Order],
[FriendlyName] AS [Friendly Name]
from DC.Field

GO
