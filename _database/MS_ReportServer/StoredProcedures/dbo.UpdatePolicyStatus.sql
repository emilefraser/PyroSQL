SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdatePolicyStatus]
    @PolicyID as uniqueidentifier,
    @AuthType int,
    @Status int
AS
    UPDATE SecData
    SET
        NtSecDescState = @Status
    WHERE
        SecData.PolicyID = @PolicyID AND SecData.AuthType = @AuthType
GO
