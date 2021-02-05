CREATE PROCEDURE [Sample].[@ExecCopyTable]

AS
RETURN
BEGIN
exec Copy_@1_@2_From_@3
END
