SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/* 
=============================================
? WHAT ? MASTEROFALL.dbo.Database_Purge
? WHY  ? Purges all database objects for repopulation
? WHO  ? Emile Fraser
? WHEN ? 2020-01-27
---------------------------------------------
Prerun: 
---------------------------------------------
Test:
DECLARE @DatabaseName SYSNAME = 'oilgasrlsdemo2016'
EXEC dbo.Database_Purge_Alternate
			@DatabaseName = @DatabaseName
=============================================
*/
CREATE   PROCEDURE [dbo].[Database_Purge_Alternate]
	@DatabaseName SYSNAME
,	@sql_debug BIT = 1
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON
	   
	BEGIN TRY
		
		BEGIN TRANSACTION

			DECLARE @sql_statement NVARCHAR(MAX)
			DECLARE @sql_parameters NVARCHAR(MAX)
			DECLARE @sql_message NVARCHAR(MAX)			
			DECLARE @sql_clrf NVARCHAR(2) = CHAR(13) + CHAR(10)
			
			-- Checks if database Exists
			IF EXISTS (
				SELECT 
					1
				FROM 
					sys.databases
				WHERE
					name = @DatabaseName
			)
			BEGIN	
				
				--DECLARE 
				--	@curs_objects CURSOR

				DECLARE  
					@Objects_ID BIGINT
				,	@Object_Type NVARCHAR(5)
				,	@Objects_Desc NVARCHAR(30)
				,	@Object_Name SYSNAME
				,	@Schema_Name SYSNAME

				--DECLARE @TVP_Objects TABLE (
				--		ObjectsID BIGINT
				--	,	ObjectType NVARCHAR(5)
				--	,	ObjectsDesc NVARCHAR(30)
				--	,	ObjectName SYSNAME
				--	,	SchemaName SYSNAME
				--)

				-- Gets all DB OBJECTS
				-- TODO	: Need to rank the elements in order we can delete/drop
				--		: For example PK/FK or references
				--		: ADD FK, PK, U, C, AF, UQ
				SET @sql_statement = (
				   '
						DECLARE curs_objects CURSOR FOR
						SELECT 
							o.object_id
						,	o.type
						,	o.type_desc
						,	o.name
						,	s.name
						FROM ' +
							@DatabaseName + '.sys.objects AS o
						INNER JOIN 
							sys.schemas AS s
							ON s.schema_id = o.schema_id
						WHERE
							o.type IN (''U'', ''V'', ''P'', ''FN'', ''TF'', ''IF'', ''SN'', ''TA'', ''TR'', ''X'')
						AND
							o.is_ms_shipped = 0
				   '
				)		

				-- Need to include @curs_objects too otherwise its outside scope./context of the dynamic proc
				SET @sql_parameters = '@DatabaseName SYSNAME'

				--SET @sql_statement = (
				--	'	
				--		DECLARE curs_objects CURSOR FOR
				--	' + @sql_clrf
				--	  + @sql_statement
				--)

				IF(@sql_debug = 1)
					RAISERROR(@sql_statement, 0, 1) WITH NOWAIT

				
				--INSERT INTO @TVP_Objects
				EXEC sp_executesql 
					@sql_stmt = @sql_statement
				,	@sql_param = @sql_parameters
				,	@DatabaseName = @databaseName

			--	SELECT * FROM @TVP_Objects

			--	SET curs_objects = CURSOR FOR	
			--	SELECT * FROM @TVP_Objects

				OPEN curs_objects

				FETCH NEXT FROM 
					curs_objects
				INTO 
					@Objects_ID
				,	@Object_Type
				,	@Objects_Desc 
				,	@Object_Name
				,	@Schema_Name
							

				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					SELECT 'aaa'

					SELECT 	
							@Objects_ID AS PAR_Objects_ID
						,	@Object_Type AS PAR_Object_Type
						,	@Objects_Desc AS PAR_Objects_Desc
						,	@Object_Name AS PAR_Object_Name
						,	@Schema_Name AS PAR_Schema_Name

					FETCH NEXT FROM 
						curs_objects
					INTO 
						@Objects_ID
					,	@Object_Type
					,	@Objects_Desc 
					,	@Object_Name
					,	@Schema_Name

				END

				CLOSE curs_objects
				DEALLOCATE curs_objects

			END

		COMMIT TRANSACTION
		
	END TRY
   
	BEGIN CATCH
		
		IF xact_state() > 0 AND @@trancount > 0 
			COMMIT TRANSACTION
		
		ELSE IF xact_state() < 0 AND @@trancount > 0 
			ROLLBACK TRANSACTION
		
		--ELSE
			
		;THROW
		
		DECLARE @ErrorNumber INT = ERROR_NUMBER()
		DECLARE @ErrorLine INT = ERROR_LINE()
		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
		DECLARE @ErrorState INT = ERROR_STATE()
 
		SET @sql_message  = '###### ERROR ######' + @sql_clrf
		SET @sql_message += 'Actual error number: ' + CAST(@ErrorNumber AS NVARCHAR(10)) + @sql_clrf
		SET @sql_message += 'Actual line number: ' + CAST(@ErrorLine AS NVARCHAR(10)) + @sql_clrf
		 
		RAISERROR(@sql_message, 16, 1) WITH NOWAIT
		
		RETURN 55555
			
	END CATCH

END


GO
