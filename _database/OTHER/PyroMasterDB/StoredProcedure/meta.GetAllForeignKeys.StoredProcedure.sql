SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[GetAllForeignKeys]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[GetAllForeignKeys] AS' 
END
GO
/*
	EXEC [adf].[GetAllForeignKeys]
*/

ALTER     PROCEDURE [meta].[GetAllForeignKeys]
AS
BEGIN
	--- SCRIPT TO GENERATE THE CREATION SCRIPT OF ALL FOREIGN KEY CONSTRAINTS
	DECLARE
		@ForeignKeyID        INT
	DECLARE
		@ForeignKeyName        VARCHAR(4000)
	DECLARE
		@ParentTableName        VARCHAR(4000)
	DECLARE
		@ParentColumn        VARCHAR(4000)
	DECLARE
		@ReferencedTable        VARCHAR(4000)
	DECLARE
		@ReferencedColumn        VARCHAR(4000)
	DECLARE
		@StrParentColumn        VARCHAR(MAX)
	DECLARE
		@StrReferencedColumn        VARCHAR(MAX)
	DECLARE
		@ParentTableSchema        VARCHAR(4000)
	DECLARE
		@ReferencedTableSchema        VARCHAR(4000)
	DECLARE
		@TSQLCreationFK        VARCHAR(MAX)
	--Written by Percy Reyes www.percyreyes.com
	DECLARE CursorFK CURSOR
	FOR SELECT
			object_id--, name, object_name( parent_object_id) 
		FROM
			[sys].[foreign_keys]
	OPEN CursorFK
	FETCH NEXT FROM CursorFK INTO
		@ForeignKeyID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @StrParentColumn = ''
		SET @StrReferencedColumn = ''
		DECLARE CursorFKDetails CURSOR
		FOR SELECT
				[fk].[name] AS [ForeignKeyName]
			  , SCHEMA_NAME([t1].schema_id) AS [ParentTableSchema]
			  , OBJECT_NAME([fkc].[parent_object_id]) AS [ParentTable]
			  , [c1].[name] AS [ParentColumn]
			  , SCHEMA_NAME([t2].schema_id) AS [ReferencedTableSchema]
			  , OBJECT_NAME([fkc].[referenced_object_id]) AS [ReferencedTable]
			  , [c2].[name] AS [ReferencedColumn]
			FROM
				--sys.tables t inner join 
				[sys].[foreign_keys] AS [fk]
			INNER JOIN
				[sys].[foreign_key_columns] AS [fkc]
				ON [fk].object_id = [fkc].[constraint_object_id]
			INNER JOIN
				[sys].[columns] AS [c1]
				ON [c1].object_id = [fkc].[parent_object_id] AND [c1].[column_id] = [fkc].[parent_column_id]
			INNER JOIN
				[sys].[columns] AS [c2]
				ON [c2].object_id = [fkc].[referenced_object_id] AND
																	 [c2].[column_id] = [fkc].[referenced_column_id]
			INNER JOIN
				[sys].[tables] AS [t1]
				ON [t1].object_id = [fkc].[parent_object_id]
			INNER JOIN
				[sys].[tables] AS [t2]
				ON [t2].object_id = [fkc].[referenced_object_id]
			WHERE [fk].object_id = @ForeignKeyID
		OPEN CursorFKDetails
		FETCH NEXT FROM CursorFKDetails INTO
			@ForeignKeyName
		  , @ParentTableSchema
		  , @ParentTableName
		  , @ParentColumn
		  , @ReferencedTableSchema
		  , @ReferencedTable
		  , @ReferencedColumn
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @StrParentColumn =
								   @StrParentColumn
								   + ', '
								   + QUOTENAME(@ParentColumn)
			SET @StrReferencedColumn =
									   @StrReferencedColumn
									   + ', '
									   + QUOTENAME(@ReferencedColumn)

			FETCH NEXT FROM CursorFKDetails INTO
				@ForeignKeyName
			  , @ParentTableSchema
			  , @ParentTableName
			  , @ParentColumn
			  , @ReferencedTableSchema
			  , @ReferencedTable
			  , @ReferencedColumn
		END
		CLOSE CursorFKDetails
		DEALLOCATE CursorFKDetails

		SET @StrParentColumn = SUBSTRING(@StrParentColumn, 2, LEN(@StrParentColumn) - 1)
		SET @StrReferencedColumn = SUBSTRING(@StrReferencedColumn, 2, LEN(@StrReferencedColumn) - 1)
		SET @TSQLCreationFK =
							  'ALTER TABLE '
							  + QUOTENAME(@ParentTableSchema)
							  + '.'
							  + QUOTENAME(@ParentTableName)
							  + ' WITH CHECK ADD CONSTRAINT '
							  + QUOTENAME(@ForeignKeyName +'_new')
							  + ' FOREIGN KEY('
							  + LTRIM(@StrParentColumn)
							  + ') '
							  + CHAR(13)
							  + 'REFERENCES '
							  + QUOTENAME(@ReferencedTableSchema)
							  + '.'
							  + QUOTENAME(@ReferencedTable)
							  + ' ('
							  + LTRIM(@StrReferencedColumn)
							  + ') '
							  + CHAR(13)
							  + 'GO'

		PRINT @TSQLCreationFK

		FETCH NEXT FROM CursorFK INTO
			@ForeignKeyID
	END
	CLOSE CursorFK
	DEALLOCATE CursorFK
END
GO
