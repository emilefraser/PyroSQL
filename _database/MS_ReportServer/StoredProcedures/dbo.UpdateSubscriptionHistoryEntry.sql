SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdateSubscriptionHistoryEntry]
	@SubscriptionHistoryID BIGINT,
	@EndTime DATETIME,
	@Status TINYINT,
	@Message NVARCHAR(1500),
	@Details NVARCHAR(4000)
AS
BEGIN

	UPDATE [dbo].[SubscriptionHistory]
	   SET [EndTime] = @EndTime
		  ,[Status] = @Status
		  ,[Message] = @Message
		  ,[Details] = @Details
	 WHERE [SubscriptionHistoryID] = @SubscriptionHistoryID

END
GRANT EXECUTE ON [dbo].[UpdateSubscriptionHistoryEntry] TO RSExecRole
GO
