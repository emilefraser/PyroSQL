SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteEvent]
@ID uniqueidentifier
AS
delete from [Event] where [EventID] = @ID
GO
