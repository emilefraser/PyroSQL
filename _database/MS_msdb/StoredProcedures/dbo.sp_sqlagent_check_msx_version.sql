SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_check_msx_version
  @required_microsoft_version INT = NULL
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @msx_version          NVARCHAR(16)
  DECLARE @required_msx_version NVARCHAR(16)

  IF (@required_microsoft_version IS NULL)
    SELECT @required_microsoft_version = 0x07000252 -- 7.0.594

  IF (@@microsoftversion < @required_microsoft_version)
  BEGIN
    SELECT @msx_version = CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), @@microsoftversion / 0x1000000 ) ) )
   + N'.'
   + CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), CONVERT( BINARY(2), ((@@microsoftversion / 0x10000) % 0x100) ) ) ) )
   + N'.'
   + CONVERT( NVARCHAR(4), @@microsoftversion % 0x10000 )

    SELECT @required_msx_version = CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), @required_microsoft_version / 0x1000000 ) ) )
   + N'.'
   + CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), CONVERT( BINARY(2), ((@required_microsoft_version / 0x10000) % 0x100) ) ) ) )
   + N'.'
   + CONVERT( NVARCHAR(4), @required_microsoft_version % 0x10000 )

   RAISERROR(14541, -1, -1, @msx_version, @required_msx_version)
    RETURN(1) -- Failure
  END
  RETURN(0) -- Success
END

GO
