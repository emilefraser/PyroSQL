SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_read_settings]
@name sysname = NULL OUTPUT, 
@setting_id int = NULL OUTPUT
AS
BEGIN
  IF ((@name IS NULL)     AND (@setting_id IS NULL)) OR
     ((@name IS NOT NULL) AND (@setting_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, '@name', '@setting_id')
    RETURN(1) -- Failure
  END

  IF (@setting_id IS NOT NULL)
  BEGIN
    SELECT @name = CASE @setting_id
      WHEN 1 THEN 'ExtendedProtection'
      WHEN 2 THEN 'ForceEncryption'
      WHEN 3 THEN 'AcceptedSPNs'
      ELSE NULL
      END
      
      IF (@name IS NULL) RETURN (2) -- Unknown key
  END
  ELSE
  BEGIN
    IF (@name collate SQL_Latin1_General_CP1_CI_AS) != 'ExtendedProtection'
      AND (@name collate SQL_Latin1_General_CP1_CI_AS) != 'ForceEncryption'
      AND (@name collate SQL_Latin1_General_CP1_CI_AS) != 'AcceptedSPNs'
      RETURN (2) -- Unknown key
  END
  
  DECLARE @hive nvarchar(32), @key nvarchar(256)
  SET @hive=N'HKEY_LOCAL_MACHINE' 
  SET @key=N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib'
  
  Execute master.sys.xp_instance_regread @hive, @key, @name
  
  RETURN (0)
END

GO
