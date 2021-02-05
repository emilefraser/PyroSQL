CREATE PROCEDURE [DSQLT].[@PrintParameter]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@PrintParameter' ,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
	if '@0' = '"@0"' 	print '@0'
	if '@1' = '"@1"' 	print '@1'
	if '@2' = '"@2"'	print '@2'
	if '@3' = '"@3"'	print '@3'
	if '@4' = '"@4"'	print '@4'
	if '@5' = '"@5"'	print '@5'
	if '@6' = '"@6"'	print '@6'
	if '@7' = '"@7"'	print '@7'
	if '@8' = '"@8"'	print '@8'
	if '@9' = '"@9"'	print '@9'
END
