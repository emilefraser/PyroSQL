CREATE FUNCTION [DSQLT].[TypePattern]
(@Pattern NVARCHAR (MAX), @Value NVARCHAR (MAX), @Type [sysname], @Len INT, @Precision INT, @Scale INT)
RETURNS NVARCHAR (MAX)
AS
BEGIN
DECLARE @Result nvarchar(max)
SET @Result=
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(@Pattern
								,'%v',@Value)
							,'%t',@Type)
						,'%l',ltrim(case when @Len=-1 then 'max' else str(@Len) end))
					,'%h',ltrim(case when @Len=-1 then 'max' else str(@Len/2) end))
				,'%p',ltrim(str(@Precision)))
			,'%s',ltrim(@Scale)) 
RETURN @Result
END
