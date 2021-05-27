CREATE PROCEDURE dbo.EH_Insert
	@ErrorHandlingMethod    VARCHAR(255),
	@InsertType		VARCHAR(255),
	@RowSplit               INT = 20000
AS
BEGIN
	SET NOCOUNT ON;
 
	-- clean up any new rows and drop buffers/clear proc cache
	EXEC dbo.EH_Cleanup;
 
	DECLARE
		@CutoffString1 NVARCHAR(255),
		@CutoffString2 NVARCHAR(255),
		@Name NVARCHAR(255),
		@Continue BIT = 1,
		@LogID INT;
 
	-- generate a new log entry
	INSERT dbo.RunTimeLog(Spid, InsertType, ErrorHandlingMethod)
		SELECT @@SPID, @InsertType, @ErrorHandlingMethod;
 
	SET @LogID = SCOPE_IDENTITY();
 
	-- if we want everything to succeed, we need a set of data
	-- that has 40,000 rows that are all unique. So union two
	-- sets that are each >= 20,000 rows apart, and don't
	-- already exist in the base table:
 
	IF @InsertType = 'AllSuccess'
		SELECT @CutoffString1 = N'database_audit_specifications_1000',
		       @CutoffString2 = N'dm_clr_properties_1398';
 
	-- if we want them all to fail, then it's easy, we can just
	-- union two sets that start at the same place as the initial
	-- population:
 
	IF @InsertType = 'AllFail'
		SELECT @CutoffString1 = N'', @CutoffString2 = N'';
 
	-- and if we want half to succeed, we need 20,000 unique
	-- values, and 20,000 duplicates:
 
	IF @InsertType = 'HalfSuccess'
		SELECT @CutoffString1 = N'database_audit_specifications_1000',
		       @CutoffString2 = N'';
 
	DECLARE c CURSOR
		LOCAL STATIC FORWARD_ONLY READ_ONLY
		FOR
			SELECT name FROM dbo.GenerateRows(@RowSplit, @CutoffString1)
			UNION ALL
			SELECT name FROM dbo.GenerateRows(@RowSplit, @CutoffString2);
 
	OPEN c;
 
	FETCH NEXT FROM c INTO @Name;
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Continue = 1;
 
		-- let's only enter the primary code block if we
		-- have to check and the check comes back empty
		-- (in other words, don't try at all if we have
		-- a duplicate, but only check for a duplicate
		-- in certain cases:
 
		IF @ErrorHandlingMethod LIKE 'Check%'
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.[Objects] WHERE Name = @Name)
				SET @Continue = 0;
		END
 
		IF @Continue = 1
		BEGIN
			-- just let the engine catch
			IF @ErrorHandlingMethod LIKE '%Insert'
			BEGIN
				INSERT dbo.[Objects](name) SELECT @name;
			END
 
			-- begin a transaction, but let the engine catch
			IF @ErrorHandlingMethod LIKE '%Rollback'
			BEGIN
				BEGIN TRANSACTION;
				INSERT dbo.[Objects](name) SELECT @name;
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END
				ELSE
				BEGIN
					COMMIT TRANSACTION;
				END
			END
 
			-- use try / catch
			IF @ErrorHandlingMethod LIKE '%TryCatch'
			BEGIN
				BEGIN TRY
					BEGIN TRANSACTION;
					INSERT dbo.[Objects](name) SELECT @Name;
					COMMIT TRANSACTION;
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION;
				END CATCH
			END
		END
 
		FETCH NEXT FROM c INTO @Name;
	END
 
	CLOSE c;
	DEALLOCATE c;
 
	-- update the log entry
	UPDATE dbo.RunTimeLog SET EndDate = SYSUTCDATETIME()
		WHERE LogID = @LogID;
 
	-- clean up any new rows and drop buffers/clear proc cache
	EXEC dbo.EH_Cleanup;
END
GO