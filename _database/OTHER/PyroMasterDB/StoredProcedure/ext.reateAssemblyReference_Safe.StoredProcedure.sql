SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ext].[reateAssemblyReference_Safe]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ext].[reateAssemblyReference_Safe] AS' 
END
GO
ALTER   PROCEDURE [ext].[reateAssemblyReference_Safe]
	@AssemblyName SYSNAME
AS 
BEGIN
--ALTER ASSEMBLY [MrGeek]
--WITH PERMISSION_SET = UNSAFE

declare @clr_name nvarchar(1000)
select @clr_name = clr_name from sys.assemblies WHERE name = @AssemblyName
SELECT @clr_name
DECLARE @clrDescription nvarchar(4000) = @clr_name;

DECLARE @clrBin VARBINARY(MAX) 
SELECT @clrBin = content from  sys.assembly_files  WHERE name = @AssemblyName
SELECT @clrBin

DECLARE @hash varbinary(64);
SET @hash = HASHBYTES('SHA2_512', @clrBin);
SELECT @hash;

EXECUTE sys.sp_add_trusted_assembly @hash, @clrDescription
 
SELECT * FROM sys.trusted_assemblies;

--EXECUTE sys.sp_drop_trusted_assembly @hash

SELECT * FROM sys.trusted_assemblies;
select * from sys.assemblies
select * from sys.assembly_files
select * from sys.assembly_modules
select * from sys.assembly_references


END
GO
