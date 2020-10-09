SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Scheduler_Header](

--all table fields, remove the ones you dont need

 @ETLLoadConfigID int,
@ScheduleExecutionIntervalMinutes int,
@ScheduleExecutionTime varchar(5),
@SchedulerHeaderID int,


 

-- required params, please do not remove

@TransactionPerson varchar(80), -- who actioned

@MasterEntity varchar(50), -- from where actioned

@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"

)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

DECLARE @isActive bit -- indicate soft delete

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'SCHEDULER.SchedulerHeader' -- table name

--create record

IF @TransactionAction = 'Create'

BEGIN

--Insert new record

--remove fields not needed, keep CreatedDT and IsActive

INSERT INTO SCHEDULER.SchedulerHeader (ETLLoadConfigID, IsActive, ScheduleExecutionIntervalMinutes, ScheduleExecutionTime, CreatedDT)

VALUES(@ETLLoadConfigID, 1, @ScheduleExecutionIntervalMinutes, @ScheduleExecutionTime, @TransactionDT)

--get primary key value to store in audit table

SET @PrimaryKeyID = (SELECT SchedulerHeaderID

FROM SCHEDULER.SchedulerHeader

--remove fields not needed

WHERE ETLLoadConfigID = @ETLLoadConfigID

AND ScheduleExecutionIntervalMinutes = @ScheduleExecutionIntervalMinutes
AND ScheduleExecutionTime = @ScheduleExecutionTime
AND  CreatedDT = @TransactionDT



)

END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

--remove fields that do not need updating

UPDATE SCHEDULER.SchedulerHeader 

SET ETLLoadConfigID = @ETLLoadConfigID,

ScheduleExecutionIntervalMinutes = @ScheduleExecutionIntervalMinutes,
ScheduleExecutionTime = @ScheduleExecutionTime,
--do not remove UpdatedDT

UpdatedDT = @TransactionDT

WHERE SchedulerHeaderID = @SchedulerHeaderID

--get primary key value to store in audit table

SET @PrimaryKeyID = @SchedulerHeaderID

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update SCHEDULER.SchedulerHeader 

SET IsActive = 0, 

UpdatedDT = @TransactionDT

WHERE SchedulerHeaderID = @SchedulerHeaderID

--get primary key value to store in audit table
            SET @PrimaryKeyID = @SchedulerHeaderID
        END

--capture json data (get primary key value to store in audit table)

SET @JSONData = (SELECT *

FROM SCHEDULER.SchedulerHeader 

WHERE SchedulerHeaderID = @SchedulerHeaderID

FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )

--call sp to store json audit data in table

EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,

@TransactionAction = @TransactionAction,

@MasterEntity = @MasterEntity,

@JSONData = @JSONData,

@TransactionDT = @TransactionDT,

@PrimaryKeyID = @PrimaryKeyID,

@TableName = @TableName

END

GO
