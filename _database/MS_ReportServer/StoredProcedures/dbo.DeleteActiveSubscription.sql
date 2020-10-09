SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteActiveSubscription]
@ActiveID uniqueidentifier
AS

delete from ActiveSubscriptions where ActiveID = @ActiveID
GO
