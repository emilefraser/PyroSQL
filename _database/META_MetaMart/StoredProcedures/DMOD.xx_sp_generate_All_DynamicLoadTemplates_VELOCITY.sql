SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Generation of DLTs for Stage Tables
	How? 
		
		DECLARE @Author VARCHAR(100) = 'Emile Fraser'
		EXEC DMOD.sp_generate_All_DynamicLoadTemplates_VELOCITY @Author
*/

CREATE PROC  [DMOD].[xx_sp_generate_All_DynamicLoadTemplates_VELOCITY] 
				@Author VARCHAR(100) 
AS


-- MASTER VARIABLE BLOCK
DECLARE @Target_TableName VARCHAR(100);
DECLARE @LoadProcID INT;
DECLARE @ProcSQL NVARCHAR(MAX);
DECLARE	@RC INT
	,	@message VARCHAR(MAX)
DECLARE @loadconfigid INT
		, @loadtypeid INT
		, @LoadTypeCode VARCHAR(250)
		, @LoadTypeName VARCHAR(250)
		, @source_dataentityid INT
		, @source_dataentityname VARCHAR(250)
		, @source_schemaname VARCHAR(50)
		, @target_dataentityid INT
		, @target_dataentityname VARCHAR(250)
		, @target_schemaname VARCHAR(50);

-- VELOCITY
DECLARE load_cursor_VELOCITY CURSOR FOR 
SELECT lc.LoadConfigID, 
           lc.LoadTypeID, 
		   lc.LoadTypeCode,
           lc.SourceDataEntityID AS SourceDataEntityID, 
           lc.Source_DEName AS SourceDataEntityName,
           lc.Target_SchemaName,
		   lc.Target_DEName AS TargetDataEntityName
    FROM DMOD.vw_LoadConfig AS lc
	INNER JOIN DC.DataEntityType AS de
	ON de.DataEntityTypeID = lc.DataEntityTypeID
    WHERE de.DataEntityTypeCode IN ('MVD', 'LVD', 'HVD')
			AND lc.config_IsActive = 1
			AND lc.loadtype_IsActive = 1 
		
			OPEN load_cursor_VELOCITY


			FETCH NEXT FROM load_cursor_VELOCITY 
			INTO @loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname
			
			WHILE @@FETCH_STATUS = 0
				BEGIN

				select '@loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname'
				select @loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname

				-- Get Final Table Name
				SET @Target_TableName = QUOTENAME(@target_dataentityname);
				SELECT @Target_TableName

				SET @message = ('Generating VELOCITY Load Proc for LoadConfig = ' + CONVERT(VARCHAR, @LoadConfigID) + ' (' + @source_dataentityname + ' to ' + @target_dataentityname + ')')
				PRINT(@message)

				-- Generate DLT
				EXECUTE @RC = DMOD.sp_generate_ddl_LoadStoredProcs 
						@LoadConfigID, 
						@Author

				

				IF(@RC = 0)
				BEGIN
					SET @message = ('VELOCITY Load Proc for SUCCESSFULLY GENERATED for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
					PRINT(CHAR(9) + @message)
				END
				ELSE
				BEGIN 
					SET @message = ('ERROR GENERATING VELOCITY Load Proc for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
					PRINT(@message)
					PRINT(@@ERROR)
				END
		
			-- GET DLT GENERATED PROCID
			SET @LoadProcID = (SELECT LoadProcID fROM DMOD.LoadProcExports  WHERE LoadConfigID = @LoadConfigID AND IsLastRun = 1)

			DECLARE @sqlProc VARCHAR(MAX) = (SELECT PScript FROM DMOD.LoadProcExports WHERE LoadProcID = @LoadProcID)
			
			
			PRINT('Deploying VELOCITY Load Proc to StageArea for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))

			SET @sqlProc = 'USE DEV_StageArea'
			PRINT(@sqlProc)
			EXEC(@sqlProc)


			SET @sqlProc = @sqlProc + CHAR(13)			
			PRINT(@sqlProc)
			EXEC(@sqlProc)

			SET @sqlProc = 'USE DataManager'
			PRINT(@sqlProc)
			EXEC(@sqlProc) 



		   FETCH NEXT FROM load_cursor_VELOCITY 
		   INTO @loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname

		END

	CLOSE load_cursor_VELOCITY
	DEALLOCATE load_cursor_VELOCITY

GO
