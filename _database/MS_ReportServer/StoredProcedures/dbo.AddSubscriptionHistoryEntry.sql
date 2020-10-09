SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddSubscriptionHistoryEntry]
	@SubscriptionID UNIQUEIDENTIFIER,
	@Type TINYINT,
	@StartTime DATETIME,
	@Status TINYINT,
	@Message NVARCHAR(1500)
AS
BEGIN

    DECLARE @Id AS bigint

	INSERT INTO [dbo].[SubscriptionHistory]
		(SubscriptionID, Type, StartTime, Status, Message)
	VALUES
		(@SubscriptionID, @Type, @StartTime, @Status, @Message)

	SELECT @Id = SCOPE_IDENTITY()

	DELETE FROM [dbo].[SubscriptionHistory] WHERE [SubscriptionID] = @SubscriptionID AND [SubscriptionHistoryID] NOT IN (
		SELECT TOP (10) [SubscriptionHistoryID]
		  FROM [dbo].[SubscriptionHistory]
		  WHERE [SubscriptionID] = @SubscriptionID
		  ORDER BY [StartTime] DESC )

    SELECT @Id AS Id

END
GRANT EXECUTE ON [dbo].[AddSubscriptionHistoryEntry] TO RSExecRole
GO
