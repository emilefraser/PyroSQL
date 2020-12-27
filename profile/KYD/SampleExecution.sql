EXEC usp_DataProfiling @Report = 1 --1 = 'ColumnDataProfiling'
                      ,@SchemaName = 'Sales'
					  ,@ObjectlisttoSearch = N''
					  ,@ExcludeTables = N''
					  ,@ExcludeColumns = N''
					  ,@ExcludeDataType = N''
--Resulset shows only one record describing the details of the field, if that field has more than 50 unique values 
--and if the field has maximum character length greater than 100
--Else resultset will show one record per unqiue value in that field
--This default value can be overwritten using below parameters
					  ,@RestrictCharlength = N'' 
					  ,@RestrictNoOfUniqueValues = N'' 

EXEC usp_DataProfiling @Report = 2 --2 = 'ColumnUniqueValues'
                      ,@SchemaName = 'Sales'
					  ,@ObjectlisttoSearch = N''
					  ,@ExcludeTables = N''
					  ,@ExcludeColumns = N''
					  ,@ExcludeDataType = N''
--Resulset shows only one record describing the details of the field, if that field has more than 50 unique values 
--and if the field has maximum character length greater than 100
--Else resultset will show one record per unqiue value in that field
--This default value can be overwritten using below parameters
					  ,@RestrictCharlength = N'' 
					  ,@RestrictNoOfUniqueValues = N'' 

EXEC usp_DataProfiling_Metadata  @Report = 1   --1 = 'TableStats'
                                ,@SchemaName = N'Sales'
                                ,@ObjectlisttoSearch = N''


EXEC usp_DataProfiling_Metadata  @Report = 2   --2 = 'TableColumnMetadata'
                                ,@SchemaName = N'Sales'
                                ,@ObjectlisttoSearch = N''