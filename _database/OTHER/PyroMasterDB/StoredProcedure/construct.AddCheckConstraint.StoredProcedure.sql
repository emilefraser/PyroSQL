SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[AddCheckConstraint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[AddCheckConstraint] AS' 
END
GO
ALTER   PROCEDURE [construct].[AddCheckConstraint]
AS
BEGIN

	ALTER TABLE 
		dbo.MyTable
	ADD CONSTRAINT 
		CHK_dbo_MyTable_Value
	CHECK
		(value > 0.00)

END
GO
