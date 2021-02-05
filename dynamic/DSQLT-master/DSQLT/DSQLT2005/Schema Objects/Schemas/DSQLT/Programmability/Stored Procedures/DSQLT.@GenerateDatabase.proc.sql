




CREATE PROCEDURE [DSQLT].[@GenerateDatabase]
@Database [sysname]=null, @Print BIT=0
AS
declare @path varchar(max)
select top 1 @path=physical_name from sys.database_files
declare @pos int
set @pos = CHARINDEX('\',REVERSE(@path))
SET @path=LEFT(@path,len(@path)-@pos+1)

exec DSQLT.[Execute] '@GenerateDatabase' ,@Database,@Path,@Print=@Print
RETURN 0
BEGIN
CREATE DATABASE [@1] ON  PRIMARY 
( NAME = N'@1', FILENAME = N'@2@1.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'@1_log', FILENAME = N'@2@1.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
ALTER DATABASE [@1] SET  READ_WRITE 
ALTER DATABASE [@1] SET RECOVERY FULL 
ALTER DATABASE [@1] SET  MULTI_USER 
ALTER DATABASE [@1] SET PAGE_VERIFY CHECKSUM  
ALTER DATABASE [@1] SET DB_CHAINING OFF 
END





