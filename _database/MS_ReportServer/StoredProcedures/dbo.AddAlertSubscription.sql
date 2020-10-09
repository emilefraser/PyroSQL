SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddAlertSubscription]
    @UserID uniqueidentifier,
    @ItemID uniqueidentifier,
    @AlertType nvarchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM AlertSubscribers WHERE
    UserID = @UserID AND
    ItemID = @ItemID AND
    AlertType = @AlertType) BEGIN
        INSERT
        INTO [AlertSubscribers] (UserID, ItemID, AlertType)
        VALUES (@UserID, @ItemID, @AlertType)
    END
END
GO
