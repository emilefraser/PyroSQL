SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_mi_get_cpu_architecture_name](@architecture INT)
RETURNS NVARCHAR(64)
AS
BEGIN
   DECLARE @architecture_name NVARCHAR(64) = N''
   SELECT @architecture_name = 
      CASE 
         WHEN @architecture = 0 THEN 'x86'
         WHEN @architecture = 1 THEN 'MIPS'
         WHEN @architecture = 2 THEN 'Alpha'
         WHEN @architecture = 3 THEN 'PowerPC'
         WHEN @architecture = 6 THEN 'Intel Itanium Processor Family (IPF)'
         WHEN @architecture = 9 THEN 'x64'
      END
   RETURN @architecture_name
END

GO
