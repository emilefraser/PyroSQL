INSERT [dbo].[QuickRun] ([SqlTextDefinition]) VALUES (N'DECLARE @cursor_table CURSOR 
	EXEC [string].[SplitStringIntoTable]
					@StringToSplit			= ''schema.table|schema1.table1|schema2.table2|schema3.table3''
				,	@EndOfLineCharcter		= ''|''
				,	@cursor_table			= @cursor_table OUTPUT')
