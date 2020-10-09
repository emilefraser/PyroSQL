SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdatePolicy]
    @PolicyID as uniqueidentifier,
    @PrimarySecDesc as image,
    @SecondarySecDesc as ntext = NULL,
    @AuthType int
AS
    UPDATE SecData
    SET
        NtSecDescPrimary = @PrimarySecDesc,
        NtSecDescSecondary = @SecondarySecDesc,
        NtSecDescState = 0 -- Setting State back to Valid
    WHERE
        SecData.PolicyID = @PolicyID AND
        SecData.AuthType = @AuthType
GO
