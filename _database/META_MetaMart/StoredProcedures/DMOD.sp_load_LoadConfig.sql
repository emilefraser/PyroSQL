SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
Proc for populating loadconfigs

EXEC DMOD.sp_load_LoadConfig 
			@LoadTypeID = 2 -- Static Load Template Type for Load
           ,@SourceDataEntityID = 12455 -- Source Data Entity
           ,@TargetDataEntityID = 40358 -- Target Data Entity
           ,@IsSetForReloadOnNextRun = 0 -- Not Used at the Moment
*/
CREATE PROCEDURE [DMOD].[sp_load_LoadConfig] 
			@LoadTypeID int
           ,@SourceDataEntityID int
           ,@TargetDataEntityID int
           ,@IsSetForReloadOnNextRun bit

AS 

DECLARE @CreatedDT DATETIME2(7) = (SELECT GETDATE())
DECLARE @IsActive BIT = 1 
DECLARE @OffsetDays INT = 0

INSERT INTO [DMOD].[LoadConfig]
           ([LoadTypeID]
           ,[SourceDataEntityID]
           ,[TargetDataEntityID]
           ,[IsSetForReloadOnNextRun]
           ,[OffsetDays]
           ,[CreatedDT]
           ,[IsActive])
     VALUES
           (
			@LoadTypeID
           ,@SourceDataEntityID
           ,@TargetDataEntityID
           ,@IsSetForReloadOnNextRun
           ,@OffsetDays
           ,@CreatedDT
           ,@IsActive
		   )

GO
