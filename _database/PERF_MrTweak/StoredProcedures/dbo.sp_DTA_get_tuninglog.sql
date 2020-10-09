SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

create procedure [dbo].[sp_DTA_get_tuninglog]
	@SessionID int,
	@XML int = 0,
    @LastRowRetrieved int = 0,
    @GetFrequencyForRowIDOnly int = 0

as
begin
	set nocount on
	declare @retval  int
	declare	@LogTableName nvarchar(1280)
	declare	@DefaultTableName nvarchar(128)
	declare @SQLString nvarchar(2048)
	--CategoryID,Event,Statement,Frequency,Reason
	declare @localized_string_CategoryID nvarchar(128)
	declare @localized_string_Event nvarchar(128)
	declare @localized_string_Statement nvarchar(128)
	declare @localized_string_Frequency nvarchar(128)
	declare @localized_string_Reason nvarchar(128)

	set @localized_string_CategoryID = N'"CategoryID"'
	set @localized_string_Event = N'"Event"'
	set @localized_string_Statement = N'"Statement"'
	set @localized_string_Frequency = N'"Frequency"'
	set @localized_string_Reason = N'"Reason"'


	exec @retval =  sp_DTA_check_permission @SessionID

	if @retval = 1
	begin
		raiserror(31002,-1,-1)
		return(1)
	end

	set @DefaultTableName = '[MrTweak].[dbo].[DTA_tuninglog]'
	set @LogTableName = ' '
	select top 1 @LogTableName = LogTableName from DTA_input where SessionID = @SessionID

	if (@LogTableName = ' ')
		return (0)


	if @XML = 0
	begin
		if (@GetFrequencyForRowIDOnly = 0)
		begin
			set @SQLString ='select CategoryID as ' + @localized_string_CategoryID + 
							' ,Event as ' +  @localized_string_Event +
							' ,Statement as ' + @localized_string_Statement +
							' ,Frequency as ' + @localized_string_Frequency +
							' ,Reason as ' + @localized_string_Reason +			
							' from '
		end
		else
		begin
			set @SQLString = N' select Frequency from '
		end
		set @SQLString = @SQLString + @LogTableName
		set @SQLString = @SQLString + N' where SessionID = '
		set @SQLString = @SQLString + CONVERT(nvarchar(10),@SessionID)
        set @SQLString = @SQLString + N' and RowID > '
        set @SQLString = @SQLString + CONVERT(nvarchar(10),@LastRowRetrieved)
        set @SQLString = @SQLString + ' order by RowID'

		exec (@SQLString)
	end
	else
	begin
		if @LogTableName = 	@DefaultTableName
		begin
			if (@GetFrequencyForRowIDOnly = 0)
			begin
				select CategoryID,Event,Statement,Frequency,Reason from [MrTweak].[dbo].[DTA_tuninglog]
				where SessionID = @SessionID and RowID > @LastRowRetrieved
				FOR XML RAW
			end
			else
			begin
				select Frequency from [MrTweak].[dbo].[DTA_tuninglog]
				where SessionID = @SessionID and RowID > @LastRowRetrieved
				FOR XML RAW
			end
			return(0)
		end

		if (@GetFrequencyForRowIDOnly = 0)
		begin
			set @SQLString = N' select CategoryID,Event,Statement,Frequency,Reason from '
		end
		else
		begin
			set @SQLString = N' select Frequency from '
		end
		set @SQLString =  @SQLString + @LogTableName
		set @SQLString = @SQLString + N' where SessionID = '
		set @SQLString = @SQLString + CONVERT(nvarchar(10),@SessionID)
        set @SQLString = @SQLString + N' and RowID > '
        set @SQLString = @SQLString + CONVERT(nvarchar(10),@LastRowRetrieved)
		set @SQLString = @SQLString + 'FOR XML RAW'

		exec (@SQLString)

	end
end

GO
