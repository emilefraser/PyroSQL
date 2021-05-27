SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetObjectDataWithType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetObjectDataWithType] AS' 
END
GO

                    ALTER PROCEDURE [dss].[SetObjectDataWithType]
                        @ObjectId UNIQUEIDENTIFIER,
                        @DataType INT,
                        @ObjectData [varbinary](max),
                        @NoModifySince rowversion = 0xFFFFFFFFFFFFFFFF
                    AS
                    BEGIN
                        IF NOT EXISTS (SELECT * FROM [dss].[SyncObjectData] WHERE [ObjectId] = @ObjectId AND [DataType] = @DataType)
                            INSERT INTO [dss].[SyncObjectData] ([ObjectId], [DataType], [ObjectData])
                                VALUES (@ObjectId, @DataType, @ObjectData);
                        ELSE BEGIN
                            UPDATE [dss].[SyncObjectData] SET [ObjectData] = @ObjectData, [DroppedTime] = NULL
                                WHERE [ObjectId] = @ObjectId AND [DataType] = @DataType AND ([LastModified] <= @NoModifySince OR [DroppedTime] IS NOT NULL)
                        END
                        SELECT [CreatedTime], [LastModified], @@ROWCOUNT AS [Updated] FROM [dss].[SyncObjectData] WHERE [ObjectId] = @ObjectId AND [DataType] = @DataType
                    END
GO
