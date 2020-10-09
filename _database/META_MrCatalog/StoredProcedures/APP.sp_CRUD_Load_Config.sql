SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Load_Config](

	--all table fields, remove the ones you dont need
	@LoadConfigID int, -- primary key table 1
	@LoadTypeID int,
	@OffsetDays int,
	@PrimaryKeyField varchar(50),
	@SourceDataEntityID int,
	--@TargetDataEntityID int, -- should be target database id
	@TargetDatabaseID int,
	@TransactionNoField varchar(50),
	@IsSetForReloadOnNextRun bit,
	@CreatedDTField varchar(50),
	@UpdatedDTField varchar(50),
	@ScheduleExecutionIntervalMinutes int,
	@ScheduleExecutionTime varchar(5),
	@NewDataFilterType varchar(50),
	-- required params, please do not remove
	@TransactionPerson varchar(80), -- who actioned
	@MasterEntity varchar(50), -- from where actioned
	@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"
)

AS

BEGIN

	DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
	DECLARE @JSONData varchar(max) = null -- to store in audit table
	DECLARE @PrimaryKeyID int = null -- primary key value for the table
	DECLARE @TableName VARCHAR(50) = 'ETL.LoadConfig' -- table name


	--change vars for int to null
	--only in cases where the other variable has a value and these ones needs a null
	IF @OffsetDays = -1
		BEGIN
			SET @OffsetDays = NULL
		END
	IF @ScheduleExecutionIntervalMinutes = -1
		BEGIN
			SET @ScheduleExecutionIntervalMinutes = NULL
		END
	SET @PrimaryKeyField = nullif(@PrimaryKeyField, 'NULL')
	SET @TransactionNoField = nullif(@TransactionNoField, 'NULL')
	SET @CreatedDTField = nullif(@CreatedDTField, 'NULL')
	SET @UpdatedDTField = nullif(@UpdatedDTField, 'NULL')
	SET @ScheduleExecutionTime = nullif(@ScheduleExecutionTime, 'NULL')
	SET @NewDataFilterType = nullif(@NewDataFilterType, 'NULL')
	
	--create record
	IF @TransactionAction = 'Create'
		BEGIN
		BEGIN TRY
        BEGIN TRANSACTION;
			--check if record exists
			IF EXISTS (SELECT 1 FROM ETL.LoadConfig WHERE  @LoadConfigID = LoadConfigID)
				BEGIN
					SELECT 'Already Exist'
				END
			ELSE
				BEGIN
				--sit hier
				Declare @NewDataEntityID int
				Declare @LogOutputID int
				EXEC [DC].[sp_CreateODSTableInDC] @NewDataEntityID OUTPUT, @LogOutputID OUTPUT, @SourceDataEntityID = @SourceDataEntityID, @TargetDatabaseID = @TargetDatabaseID
	
	--DECLARE @LogID int	
	--INSERT INTO	FS.Logging_Header (  LogTypeID
	--								,StartDT
	--								,[Description])
	--VALUES(1 , GETDATE(), 'ODS App Loader run')
	--SET @LogID = @@IDENTITY
				
	--IF @LogOutputID = 1
	--BEGIN 
	--INSERT INTO FS.Logging_Steps( LogID
	--							 ,StepNo
	--							 ,[Platform]
	--							 ,[Action]
	--							 ,StartDT
	--							 ,FinishDT
	--							 ,Duration
	--							 ,IsError
	--							  )
	--VALUES(@LogID , 1,'SQL Server','ODS table has been added to the DC.',GETDATE(),GETDATE(),0,0)
	--END
	--IF @LogOutputID = 0 
	--BEGIN 
	--INSERT INTO FS.Logging_Steps( LogID
	--							 ,StepNo
	--							 ,[Platform]
	--							 ,[Action]
	--							 ,StartDT
	--							 ,FinishDT
	--							 ,Duration
	--							 ,IsError
	--							  )
	--VALUES(@LogID , 1,'SQL Server','ODS table already exists in the DC.',GETDATE(),GETDATE(),0,0)
	--END


					--Insert new record
					--remove fields not needed, keep CreatedDT and IsActive
						--insert into header table
						INSERT INTO ETL.LoadConfig (
													CreatedDTField,
													UpdatedDTField,
													IsSetForReloadOnNextRun, 
													LoadTypeID,
													NewDataFilterType, 
													OffsetDays, 
													PrimaryKeyField, 
													SourceDataEntityID, 
													TargetDataEntityID, 
													TransactionNoField,
													isActive,
													CreatedDT
													)
						VALUES(
								@CreatedDTField,
								@UpdatedDTField,
								@IsSetForReloadOnNextRun, 
								@LoadTypeID,
								@NewDataFilterType, 
								@OffsetDays, 
								@PrimaryKeyField, 
								@SourceDataEntityID, 
								@NewDataEntityID, 
								@TransactionNoField,
								1,
								@TransactionDT
								)

						SET @PrimaryKeyID = SCOPE_IDENTITY() -- for auditing, get id
	
						--insert into detail table
						INSERT INTO [SCHEDULER].[SchedulerHeader] (ETLLoadConfigID,ScheduleExecutionIntervalMinutes,ScheduleExecutionTime,IsActive,CreatedDT)
						VALUES(@PrimaryKeyID,@ScheduleExecutionIntervalMinutes,@ScheduleExecutionTime,1,@TransactionDT)
				END

					--Create create table statement for the ODS dataentityID
	DECLARE @DDLScript varchar(max)
	DECLARE @TargetDatabaseName varchar(50) =   (SELECT DatabaseName 
												 FROM DC.[DataBase] db
												 INNER JOIN DC.[SCHEMA] s ON
												 s.DatabaseID = db.DatabaseID
												 INNER JOIN DC.[DataEntity] de ON
												 de.SchemaID = s.SchemaID
												 WHERE DataEntityID = @NewDataEntityID)
	EXECUTE [DMOD].[sp_ddl_CreateTableFromDC] 
	@DDLScript OUTPUT
	,@DataEntityID = @SourceDataEntityID,
	@TargetDatabaseName =   @TargetDatabaseName  
	--BEGIN 
	--INSERT INTO FS.Logging_Steps( LogID
	--							 ,StepNo
	--							 ,[Platform]
	--							 ,[Action]
	--							 ,StartDT
	--							 ,FinishDT
	--							 ,Duration
	--							 ,IsError
	--							  )
	--VALUES(@LogID , 2,'SQL Server','Table DDL has been created',GETDATE(),GETDATE(),0,0)
	--END


	--Insert the create table statement into the load queue
	EXECUTE  [EXECUTION].[sp_ins_DDLExecutionItem] 
   @SqlText = @DDLScript
  ,@QueryDescription = 'Create ODS Table'
  ,@TargetDatabaseInstanceID = @TargetDatabaseID
  ,@DynamicKeyword = 'ODS'

	COMMIT TRANSACTION;  
    END TRY
    BEGIN CATCH

	EXEC [APP].[sp_Report_Error];
	      -- Test if the transaction is uncommittable.  
        IF (XACT_STATE()) = -1  
        BEGIN  
            PRINT  N'The transaction is in an uncommittable state.' +  
                    'Rolling back transaction.'  
            ROLLBACK TRANSACTION;  
        END;  
        
        -- Test if the transaction is committable.  
        IF (XACT_STATE()) = 1  
        BEGIN  
            PRINT N'The transaction is committable.' +  
                'Committing transaction.'  
            COMMIT TRANSACTION; 
		END
	END CATCH
END -- create if

	--update record
	IF @TransactionAction = 'Update'
		BEGIN
			--check if record exists
			IF EXISTS (SELECT 1 FROM ETL.LoadConfig WHERE  @LoadConfigID = LoadConfigID)
				BEGIN
					--update existing record
					UPDATE ETL.LoadConfig 
					--remove fields not needed, keep UpdatedDT
					SET 
					IsSetForReloadOnNextRun = @IsSetForReloadOnNextRun,
					LoadTypeID = @LoadTypeID,
					OffsetDays = @OffsetDays,
					NewDataFilterType = @NewDataFilterType,
					PrimaryKeyField = @PrimaryKeyField,
					TransactionNoField = @TransactionNoField,
					UpdatedDTField = @UpdatedDTField,
					CreatedDTField = @CreatedDTField,
					UpdatedDT = @TransactionDT
					WHERE LoadConfigID = @LoadConfigID
				
					-- Update Scheduler 
					UPDATE SCHEDULER.SchedulerHeader 
					SET 
					ScheduleExecutionIntervalMinutes = @ScheduleExecutionIntervalMinutes,
					ScheduleExecutionTime = @ScheduleExecutionTime,
					UpdatedDT = @TransactionDT
					WHERE ETLLoadConfigID = @LoadConfigID

					SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id

				END
		END

	--delete record
	IF @TransactionAction = 'Delete'
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update ETL.LoadConfig 
			SET isActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE LoadConfigID = @LoadConfigID

			Update SCHEDULER.SchedulerHeader
			SET IsActive = 0
			WHERE ETLLoadConfigID = @LoadConfigID

			SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
		END

	--reload option for record
	IF @TransactionAction = 'Reload'
		BEGIN
			--set record status for reload (0 or 1)
			Update ETL.LoadConfig 
			SET IsSetForReloadOnNextRun = @IsSetForReloadOnNextRun, 
			UpdatedDT = @TransactionDT
			WHERE LoadConfigID = @LoadConfigID

			SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
		END

	--reactivate function (do seperately as we need to reactivate and audit 2 tables together
	IF @TransactionAction = 'UnDelete'
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update ETL.LoadConfig 
			SET isActive = 1, 
			UpdatedDT = @TransactionDT
			WHERE LoadConfigID = @LoadConfigID

			Update SCHEDULER.SchedulerHeader
			SET IsActive = 1
			WHERE ETLLoadConfigID = @LoadConfigID

			SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
		END

	--capture json data (get primary key value to store in audit table)
	--temp audit table to get record into 1 json string
	DECLARE @AuditRecordTable Table
	(
		SourceServerName varchar(100),
		SourceDatabaseInstanceName varchar(50),
		SourceDatabaseName varchar(100),
		SourceSchemaName varchar(100),
		SourceDataEntityName varchar(100),
		TargetServerName varchar(100),
		TargetDatabaseInstanceName varchar(50),
		TargetDatabaseName varchar(100),
		TargetSchemaName varchar(100),
		TargetDataEntityName varchar(100),
		LoadType varchar(50),
		PrimaryKeyField varchar(50),
		CreatedDTField varchar(50),
		UpdatedDTField varchar(50),
		IsActive bit,
		ScheduleExecutionIntervalMinutes int,
		ScheduleExecutionTime varchar(5),
		CreatedDT datetime2(7),
		UpdatedDT datetime2(7)
	)

	--insert record into temp audit table to get all into one line
	INSERT INTO @AuditRecordTable(
		SourceServerName, SourceDatabaseInstanceName, SourceDatabaseName, SourceSchemaName, SourceDataEntityName,
		TargetServerName, TargetDatabaseInstanceName, TargetDatabaseName, TargetSchemaName, TargetDataEntityName,
		LoadType, PrimaryKeyField, CreatedDTField, UpdatedDTField, IsActive,
		ScheduleExecutionIntervalMinutes, ScheduleExecutionTime, CreatedDT, UpdatedDT)
		SELECT ETL.SourceServerName, ETL.SourceDatabaseInstanceName, ETL.SourceDatabaseName, 
			ETL.SourceSchemaName, ETL.SourceDataEntityName, ETL.TargetServerName, 
			ETL.TargetDatabaseInstanceName,	ETL.TargetDatabaseName, ETL.TargetSchemaName, 
			ETL.TargetDataEntityName, ETL.LoadTypeName, ETL.PrimaryKeyField, ETL.CreatedDTField, 
			ETL.UpdatedDTField, ETL.IsActive, SH.ScheduleExecutionIntervalMinutes,
			SH.ScheduleExecutionTime, SH.CreatedDT, SH.UpdatedDT 
	--FROM [INTEGRATION].[vw_egress_ETLLoadConfig] ETL
    FROM [ETL].[vw_mat_ODSLoadConfigDetails] ETL
	inner join [SCHEDULER].[SchedulerHeader] SH
	on ETL.LoadConfigID = SH.ETLLoadConfigID
	WHERE [LoadConfigID] = @PrimaryKeyID

	--get one liner json
	SET @JSONDATA = (SELECT * FROM @AuditRecordTable FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES)
	
	--call sp to store json audit data in table
	EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
	@TransactionAction = @TransactionAction,
	@MasterEntity = @MasterEntity,
	@JSONData = @JSONData,
	@TransactionDT = @TransactionDT,
	@PrimaryKeyID = @PrimaryKeyID,
	@TableName = @TableName





	--BEGIN 
	--INSERT INTO FS.Logging_Steps( LogID
	--							 ,StepNo
	--							 ,[Platform]
	--							 ,[Action]
	--							 ,StartDT
	--							 ,FinishDT
	--							 ,Duration
	--							 ,IsError
	--							  )
	--VALUES(@LogID , 3,'SQL Server','Security hashing was added to DDL statement',GETDATE(),GETDATE(),0,0)
	--END
	
END

GO
