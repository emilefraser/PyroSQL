SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[FKBuildScript]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'crEATE function [meta].[FKBuildScript] (@Tableobject_ID int)
/*
This function returns an ALTER TABLE  build script as a string that builds all the foreigh keys constraints for the table whose ID you pass to it..

Author: Phil Factor
Revision: 1.1  
date: 1 Dec 2012
Revision: 1.2 
date: 3 Dec 2012
example:
     - code: Select dbo.FKBuildScript (object_ID(''MyTable''))

returns:   >
string Build_Script.
*/
Returns   Varchar(MAX)
as 
begin
Declare @TableForeignKeys Varchar(max)
SELECT
	@TableForeignKeys = Coalesce(@TableForeignKeys + '',
'', '''') + '' CONSTRAINT '' + QuoteName(Name) + '' FOREIGN KEY  (#'' + Convert(Varchar(10), Object_Id) + ''##1) 
     REFERENCES '' + QuoteName(Object_Schema_Name(referenced_Object_Id)) + ''.'' + QuoteName(Object_Name(referenced_Object_Id))
	+ '' (#'' + +Convert(Varchar(10), Object_Id) + ''##2)'' 
    + CASE WHEN Delete_Referential_Action>0 THEN '' ON DELETE ''+Delete_Referential_Action_Desc ELSE '''' END
	+ CASE WHEN Update_Referential_Action>0 THEN '' ON Update ''+Update_Referential_Action_Desc ELSE '''' END
	+ CASE WHEN is_not_for_replication >0 THEN '' NOT FOR REPLICATION'' ELSE '''' END
	
    FROM Sys.Foreign_Keys
WHERE TYPE = ''F'' AND Parent_Object_Id = @Tableobject_ID

SELECT
	@TableForeignKeys
	= Replace(
	Replace(@TableForeignKeys,
	''#'' + Convert(Varchar(10), Constraint_Object_Id) + ''##1'',
	QuoteName(ReferEnCer.Name) + '', #'' + Convert(Varchar(10), Constraint_Object_Id) + ''##1'' COLLATE Database_Default),
	''#'' + Convert(Varchar(10), Constraint_Object_Id) + ''##2'',
	QuoteName(Referenced.Name) + '', #'' + Convert(Varchar(10), Constraint_Object_Id) + ''##2'' COLLATE Database_Default)
    FROM Sys.Foreign_Key_Columns
			INNER JOIN Sys.Columns Referenced
				ON Referenced_Object_Id = Referenced.Object_Id
				AND Referenced_Column_Id = Referenced.Column_Id
			INNER JOIN Sys.Columns ReferEnCer
				ON Parent_Object_Id = ReferEnCer.Object_Id
				AND Parent_Column_Id = ReferEnCer.Column_Id
WHERE Parent_Object_Id = @Tableobject_ID

SELECT
	@TableForeignKeys
	= Replace(
	Replace(@TableForeignKeys, '', #'' + Convert(Varchar(10), Object_Id) + ''##1'', ''''),
	'', #'' + Convert(Varchar(10), Object_Id) + ''##2'', '''')
FROM Sys.Foreign_Keys
WHERE TYPE = ''F'' AND Parent_Object_Id = @Tableobject_ID
Return  coalesce(''ALTER TABLE [dbo].[''+Object_Name( @Tableobject_ID)+'']  WITH CHECK  
ADD '' +@TableForeignKeys,'''')
end


' 
END
GO
