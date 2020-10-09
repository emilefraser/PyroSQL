SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
CREATE VIEW dbo.sysdatatypemappings AS SELECT * FROM sys.fn_helpdatatypemap('%', '%', '%', '%', '%', '%', 0)
GO
