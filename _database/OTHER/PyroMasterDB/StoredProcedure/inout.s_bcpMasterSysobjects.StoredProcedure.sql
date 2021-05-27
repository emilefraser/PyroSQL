SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[s_bcpMasterSysobjects]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[s_bcpMasterSysobjects] AS' 
END
GO




ALTER proc [inout].[s_bcpMasterSysobjects]
@ExtractID int
as
declare @rowcount int
	set nocount on
	
	-- header - column headers
	insert	Extract (Extract_ID, Seq1, Data)
	select	@ExtractID,
			'01' ,
			'"name","crdate","crtime"'
	
	-- data
	insert	Extract (Extract_ID, Seq1, Seq2, Data)
	select	@ExtractID,
			'02' ,
			+ convert(varchar(100), '99990101' - crdate, 121) ,
					'"' + name + '"'
			+ ',' +	'"' + convert(varchar(8), crdate, 112) + '"'
			+ ',' +	'"' + convert(varchar(8), crdate, 108) + '"'
	from master..sysobjects

	select @rowcount = @@rowcount
	
	-- trailer - rowcount
	insert	Extract (Extract_ID, Seq1, Data)
	select	@ExtractID,
			'03' ,
			'rowcount = ' + convert(varchar(20),@rowcount)
GO
