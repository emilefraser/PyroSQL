USE [DataManager]
GO
/****** Object:  StoredProcedure [APP].[sp_CRUD_Database]    Script Date: 2020/05/26 04:13:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 


ALTER PROCEDURE [APP].[sp_CRUD_Database](

 

--all table fields, remove the ones you dont need
@DatabaseID int,
@DatabaseName varchar(100),
@AccessInstructions varchar(500), 
@ExternalDatasourceName varchar(100),
@DatabaseInstanceID int,
@SystemID int,
@DatabasePurposeID int,
@DBDatabaseID int,
@DatabaseEnvironmentTypeID INT,
@Size decimal(19,6),
@IsActive bit,
@IsBaseDatabase bit,
@BaseReferenceDatabaseID int,
-- required params, please do not remove
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"
)

 

AS

 

BEGIN

 

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction
DECLARE @JSONData varchar(max) = null -- to store in audit table
DECLARE @PrimaryKeyID int = null -- primary key value for the table
DECLARE @TableName VARCHAR(50) = 'DC.[Database]' -- table name

 


SET @Size = nullif(@Size, 0)
SET @DBDatabaseID = nullif(@DBDatabaseID, 0)
SET @AccessInstructions = nullif(@AccessInstructions, 'NULL')
SET @ExternalDatasourceName = nullif(@ExternalDatasourceName, 'NULL')

 

IF @BaseReferenceDatabaseID = -1
    BEGIN
        SET @BaseReferenceDatabaseID = NULL
    END

 

IF @DatabaseInstanceID = -1
    BEGIN
        SET @DatabaseInstanceID = NULL
    END

 

--create record
IF @TransactionAction = 'Create'
    BEGIN
        --Insert new record
        --remove fields not needed, keep CreatedDT and IsActive
        INSERT INTO [DC].[Database] (DatabaseName,
                                    AccessInstructions, 
                                    Size,  
                                    DatabaseInstanceID,
                                    SystemID,
                                    ExternalDatasourceName,
                                    DatabasePurposeID,
                                    DBDatabaseID,
                                    DatabaseEnvironmentTypeID,
                                    IsBaseDatabase,
                                    BaseReferenceDatabaseID,
                                    IsActive,
                                    CreatedDT)
        VALUES(@DatabaseName,
               @AccessInstructions,
               @Size,  
               @DatabaseInstanceID,
               @SystemID,
               @ExternalDatasourceName,
               @DatabasePurposeID,
               @DBDatabaseID,
               @DatabaseEnvironmentTypeID,
               @IsBaseDatabase,
               @BaseReferenceDatabaseID,
               @IsActive,
               @TransactionDT)
        
        SET @PrimaryKeyID = SCOPE_IDENTITY()  --for auditing
    END

 

--update record

 

IF @TransactionAction = 'Update'
    BEGIN
        --update existing record
        UPDATE [DC].[Database]
        SET 
        DatabaseName = @DatabaseName,
        AccessInstructions = @AccessInstructions,
        DatabaseInstanceID = @DatabaseInstanceID,
        ExternalDatasourceName = @ExternalDatasourceName,
        Size = @Size,
        SystemID = @SystemID,
        IsActive = @IsActive,
        DatabasePurposeID = @DatabasePurposeID,
        DBDatabaseID = @DBDatabaseID,
        DatabaseEnvironmentTypeID = @DatabaseEnvironmentTypeID,
        IsBaseDatabase = @IsBaseDatabase,
        BaseReferenceDatabaseID = @BaseReferenceDatabaseID,
        UpdatedDT = @TransactionDT
        WHERE DatabaseID = @DatabaseID
        
        SET @PrimaryKeyID = @DatabaseID --for auditing
    END

 

--delete record
IF @TransactionAction = 'Delete'
    BEGIN
        --set record status inactive = 0 (soft delete record)
        Update [DC].[Database]
        SET IsActive = 0, 
        UpdatedDT = @TransactionDT
        WHERE DatabaseID = @DatabaseID
        
        SET @PrimaryKeyID = @DatabaseID --for auditing
    END

 

--capture json data (get primary key value to store in audit table)
--correct audit data
SET @JSONData = (SELECT       
         [Database Name]
        ,[Access Instructions]
        ,[Size]
        ,[Database Instance Name]
        ,[System Name]
        ,[External Datasource Name]
        ,[Database Purpose Name]
        ,[Is Base Database]
        ,[Base Reference Database Name]
        ,[Created Date]
        ,[Updated Date]
        ,[Is Active]
        ,[Last Seen Date Time]
  FROM [DC].[vw_mat_Database]
WHERE [Database ID] = @PrimaryKeyID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES )

 

--call sp to store json audit data in table

 

EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
@TransactionAction = @TransactionAction,
@MasterEntity = @MasterEntity,
@JSONData = @JSONData,
@TransactionDT = @TransactionDT,
@PrimaryKeyID = @PrimaryKeyID,
@TableName = @TableName

 

END
 