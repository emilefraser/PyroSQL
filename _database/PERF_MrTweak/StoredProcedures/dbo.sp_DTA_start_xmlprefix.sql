SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_start_xmlprefix]
as
begin
	declare @startTags nvarchar(128)
	set @startTags = N'<DTAXML><DTAOutput><AnalysisReport>'
	select @startTags
end

GO
