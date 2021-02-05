CREATE PROCEDURE [DSQLT].[@GenerateTable]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@GenerateTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
	DECLARE @Result int
	exec @Result=DSQLT.DSQLT.[@isTable] '[@0]','[@1]','[@2]'
	IF @Result=1
			exec DSQLT.DSQLT.[@DropTable] '[@0]','[@1]','[@2]'

	CREATE TABLE [@1].[@2](
		"[@1]" [nvarchar](max) NOT NULL,
		"[@2]" [nvarchar](max) NOT NULL,
		"[@3]" [nvarchar](max) NOT NULL,
		"[@4]" [nvarchar](max) NOT NULL,
		"[@5]" [nvarchar](max) NOT NULL,
		"[@6]" [nvarchar](max) NULL,
		"[@7]" [nvarchar](max) NULL,
		"[@8]" [nvarchar](max) NULL,
		"[@9]" [nvarchar](max) NULL
	) ON [PRIMARY]
END