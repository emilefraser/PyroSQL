SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE procedure [dbo].[sp_TestingDDL]
@DataEntityIDInput int
as


--DECLARE @RC varchar(max)
DECLARE @DDLScript varchar(max)
--DECLARE @DataEntityID int
declare @TargetDataBaseName varchar(100) = 'DEV_StageArea'


EXECUTE [DMOD].[sp_ddl_CreateTableFromDC] 
   @DDLScript OUTPUT
  ,@DataEntityID = @DataEntityIDInput
  ,@TargetDataBaseName = '@DEV_StageArea'

DECLARE @SqlText varchar(max)
DECLARE @QueryDescription varchar(1000)
DECLARE @TargetDatabaseInstanceID int
DECLARE @DynamicKeyword varchar(1000)
DECLARE @DEName varchar(100)

-- TODO: Set parameter values here.

set		@DEName = (select distinct DataEntityName
from	DC.DataEntity
where	DataEntityID = @DataEntityIDInput)

EXECUTE  [EXECUTION].[sp_ins_DDLExecutionItem] 
   @SqlText = @DDLScript
  ,@QueryDescription = @DEName
  ,@TargetDatabaseInstanceID = 3
  ,@DynamicKeyword = 'HUB'

GO
