SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddDataModelDataSource]
    @ItemID uniqueidentifier,
    @DSType VARCHAR(100),
    @DSKind VARCHAR(100),
    @AuthType VARCHAR(100),
    @ConnectionString varbinary(max) = null,
    @Username varbinary(max) = null,
    @Password varbinary(max) = null,
    @CreatedByID uniqueidentifier,
    @ModelConnectionName varchar(260)
AS
BEGIN
DECLARE @now as datetime
SET @now = GETDATE()
INSERT INTO DataModelDataSource
         (
           [ItemId]
          ,[DSType]
          ,[DSKind]
          ,[AuthType]
          ,[ConnectionString]
          ,[Username]
          ,[Password]
          ,[CreatedByID]
          ,[CreatedDate]
          ,[ModifiedByID]
          ,[ModifiedDate]
          ,[ModelConnectionName]
          )
    VALUES
        (@ItemID,
        @DSType,
        @DSKind,
        @AuthType,
        @ConnectionString,
        @Username,
        @Password,
        @CreatedByID,
        @now,
        @CreatedByID,
        @now,
        @ModelConnectionName)
END
GO
