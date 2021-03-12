SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[RemoveObjectData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[RemoveObjectData] AS' 
END
GO

                    ALTER PROCEDURE [dss].[RemoveObjectData]
                        @ObjectId UNIQUEIDENTIFIER,
                        @DataType     INT = null,
                        @RemoveRecord BIT = 0
                    AS
                    BEGIN
                        IF @RemoveRecord = 0
                            UPDATE [dss].[SyncObjectData] SET [DroppedTime] = GETUTCDATE()
                                WHERE [ObjectId] = @ObjectId AND (@DataType IS NULL OR [DataType] = @DataType);
                        ELSE
                            DELETE FROM [dss].[SyncObjectData]
                                WHERE [ObjectId] = @ObjectId AND (@DataType IS NULL OR [DataType] = @DataType);
                    END
GO
