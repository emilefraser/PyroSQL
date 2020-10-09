SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 19 Oct 2018
-- Description: Inserts a DDL Execution Item into the queue table.
-- =============================================

CREATE PROCEDURE [EXECUTION].[sp_ins_DDLExecutionItem]
	@SqlText VARCHAR(MAX),
	@QueryDescription VARCHAR(1000),
	@TargetDatabaseInstanceID INT,
	@DynamicKeyword varchar(1000)
AS


INSERT INTO [EXECUTION].[DDLExecutionQueue]
           ([DDLQueryText]
           ,[DDLQueryDescription]
           ,[TargetDatabaseInstanceID]
           ,[Result]
		   ,[CreatedDT]
           ,[ErrorMessage]
		   ,[DDLHashCheck])
VALUES	   (@SqlText,
			@QueryDescription,
			@TargetDatabaseInstanceID,
			'Pending',
			GETDATE(),
			NULL,	
			CONVERT	(VARCHAR(40),
					HASHBYTES	('SHA1',
								 CONVERT(VARCHAR(MAX),
										 COALESCE(UPPER(LTRIM(RTRIM(@SqlText))),'') + '|' + 
										 COALESCE(UPPER(LTRIM(RTRIM(@DynamicKeyword))),'')
										 )
								)
					,2)
			)

GO
