SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_generate_server_description
  @description NVARCHAR(100) = NULL OUTPUT,
  @result_set  BIT = 0
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @xp_results TABLE
  (
  id              INT           NOT NULL,
  name            NVARCHAR(30)  COLLATE database_default NOT NULL,
  internal_value  INT           NULL,
  character_value NVARCHAR(212) COLLATE database_default NULL
  )
  INSERT INTO @xp_results
  EXECUTE master.dbo.xp_msver

  UPDATE @xp_results
  SET character_value = FORMATMESSAGE(14205)
  WHERE (character_value IS NULL)

  SELECT @description = (SELECT character_value FROM @xp_results WHERE (id = 1)) + N' ' +
                        (SELECT character_value FROM @xp_results WHERE (id = 2)) + N' / Windows ' +
                        (SELECT character_value FROM @xp_results WHERE (id = 15)) + N' / ' +
                        (SELECT character_value FROM @xp_results WHERE (id = 16)) + N' ' +
                        (SELECT CASE character_value
                                  WHEN N'PROCESSOR_INTEL_386'     THEN N'386'
                                  WHEN N'PROCESSOR_INTEL_486'     THEN N'486'
                                  WHEN N'PROCESSOR_INTEL_PENTIUM' THEN N'Pentium'
                                  WHEN N'PROCESSOR_MIPS_R4000'    THEN N'MIPS'
                                  WHEN N'PROCESSOR_ALPHA_21064'   THEN N'Alpha'
                                  ELSE character_value
                                END
                         FROM @xp_results WHERE (id = 18)) + N' CPU(s) / ' +
                        (SELECT CONVERT(NVARCHAR, internal_value) FROM @xp_results WHERE (id = 19)) + N' MB RAM.'
  IF (@result_set = 1)
    SELECT @description
END

GO
