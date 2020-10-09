SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.printall 
AS
declare @sqlAll as nvarchar(max)
set @sqlAll = '-- Insert all your sql here'

print '@sqlAll - truncated over 4000'
print @sqlAll
print '   '
print '   '
print '   '

print '@sqlAll - split into chunks'
declare @i int = 1, @nextspace int = 0, @newline nchar(2)
set @newline = nchar(13) + nchar(10)


while Exists(Select(Substring(@sqlAll,@i,3000))) and (@i < LEN(@sqlAll))
begin
    while Substring(@sqlAll,@i+3000+@nextspace,1) <> ' ' and Substring(@sqlAll,@i+3000+@nextspace,1) <> @newline
    BEGIN
        set @nextspace = @nextspace + 1
    end
    print Substring(@sqlAll,@i,3000+@nextspace)
    set @i = @i+3000+@nextspace
    set @nextspace = 0
end
print '   '
print '   '
print '   '

GO
