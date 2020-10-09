SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetSubscriptionHistory]
	@SubscriptionID UNIQUEIDENTIFIER
AS
BEGIN

	SELECT
		[SubscriptionID],
		[SubscriptionHistoryID],
		[Type],
		[StartTime],
		[EndTime],
		[Status],
		[Message],
		[Details]
	FROM
		[SubscriptionHistory]
	WHERE
		[SubscriptionID] = @SubscriptionID
	ORDER BY [StartTime] DESC

END
GRANT EXECUTE ON [dbo].[GetSubscriptionHistory] TO RSExecRole
GO
