SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteNotification]
@ID uniqueidentifier
AS
delete from [Notifications] where [NotificationID] = @ID
GO
