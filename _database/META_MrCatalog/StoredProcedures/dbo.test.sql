SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [dbo].[test] -- or create
AS
  BEGIN try
      DECLARE @retval INT;

      DECLARE @t TABLE(x INT CHECK (x = 0))

      INSERT INTO @t
      VALUES      (1)

      SET @retval = 0;

      SELECT @retval;

      RETURN( @retval );
  END try

  BEGIN catch
      --PRINT XACT_STATE()

      PRINT ERROR_MESSAGE();

      SET @retval = -1;

      SELECT @retval;

      RETURN( @retval );
  END catch; 

GO
