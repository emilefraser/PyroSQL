SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[XmlFileImport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[XmlFileImport] AS' 
END
GO


ALTER PROCEDURE [inout].[XmlFileImport]

(

	@XML_FILE NVARCHAR(MAX)

)

AS

-- Setup XML variable to be used to hold contents of XML file.

DECLARE @xml XML 

/* Read the XML file into the XML variable.  This is done via a bulk insert using the OPENROWSET()

function.   Because this stored proc is to be re-used with different XML files, ideally you want to pass

the XML file path as a variable.  However, because the OPENROWSET() function won't accept

variables as a parameter, the command needs to be built as a string and then passed to the

sp_executesql system stored procedure.  The results are then passed back by an output variable.

*/

-- The command line

DECLARE @COMMAND NVARCHAR(MAX)

-- The definition of the parameters used within the command line

DECLARE @PARAM_DEF NVARCHAR(500)

-- The parameter used to pass the file name into the command

DECLARE @FILEVAR NVARCHAR(MAX)

-- The output variable that holds the results of the OPENROWSET()

DECLARE @XML_OUT XML 

SET @FILEVAR = @XML_FILE

SET @PARAM_DEF = N'@XML_FILE NVARCHAR(MAX), @XML_OUT XML OUTPUT'

SET @COMMAND = N'SELECT @XML_OUT = BulkColumn FROM OPENROWSET(BULK ''' +  @XML_FILE + ''', SINGLE_BLOB) ROW_SET';

EXEC sp_executesql @COMMAND, @PARAM_DEF, @XML_FILE = @FILEVAR,@XML_OUT = @xml OUTPUT;

--SELECT @xml
GO
