SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[uftReadfileAsTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'Create FUNCTION [inout].[uftReadfileAsTable]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS 
@File TABLE
(
[LineNo] int identity(1,1), 
line varchar(8000)) 

AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String VARCHAR(8000),
		@YesOrNo INT

select @strErrorMessage=''opening the File System Object''
EXECUTE @hr = sp_OACreate  ''Scripting.FileSystemObject'' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage=''Opening file "''+@path+''\''+@filename+''"'',@command=@path+''\''+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , ''OpenTextFile''
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage=''finding out if there is more to read in "''+@filename+''"''
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, ''AtEndOfStream'', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage=''reading from the output file "''+@filename+''"''
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Readline'', @String OUTPUT
	INSERT INTO @file(line) SELECT @String
	END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage=''closing the output file "''+@filename+''"''
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Close''


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage=''Error whilst ''
			+coalesce(@strErrorMessage,''doing something'')
			+'', ''+coalesce(@Description,'''')
	insert into @File(line) select @strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END
' 
END
GO
