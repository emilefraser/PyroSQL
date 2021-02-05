CREATE PROCEDURE [@1].[@@2]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@1.@@2' ,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
print 0
END
