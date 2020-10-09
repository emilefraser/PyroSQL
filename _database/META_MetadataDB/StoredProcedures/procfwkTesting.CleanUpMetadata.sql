SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [procfwkTesting].[CleanUpMetadata]
AS
BEGIN
	EXEC [procfwkHelpers].[DeleteMetadataWithIntegrity];
	EXEC [procfwkHelpers].[DeleteMetadataWithoutIntegrity];
END;

GO
