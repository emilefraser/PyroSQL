SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetObjectDataWithType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetObjectDataWithType] AS' 
END
GO

                    ALTER PROCEDURE [dss].[GetObjectDataWithType]
                        @ObjectId UNIQUEIDENTIFIER,
                        @DataType INT
                    AS
                    BEGIN
                        SELECT [ObjectId]
                            ,[CreatedTime]
                            ,[DroppedTime]
                            ,[LastModified]
                            ,[ObjectData]
                        FROM [dss].[SyncObjectData]
                        WHERE [ObjectId] = @ObjectId AND [DataType] = @DataType AND [DroppedTime] IS NULL
                    END
GO
