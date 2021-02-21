SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dba_recompile_sp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dba_recompile_sp] AS' 
END
GO

ALTER Procedure [dba].[dba_recompile_sp]

        /* Declare Parameters */
          @databaseName nvarchar(128) = Null /* Null = all databases */
        , @tableName    nvarchar(128) = Null /* Null = all tables */        

As
/**********************************************************************************************************

    NAME:           dba_recompile_sp

    SYNOPSIS:       Recompiles all procs in a specific database or all procs; can recompile a specific table, too.

    DEPENDENCIES:   The following dependencies are required to execute this script:
                    - SQL Server 2005 or newer

    AUTHOR:         Michelle Ufford, http://sqlfool.com
    
    CREATED:        2009-09-12
    
    VERSION:        1.0

    LICENSE:        Apache License v2

    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------

 ---------------------------------------------------------------------------------------------------------
 --  DATE       VERSION     AUTHOR                  DESCRIPTION                                        --
 ---------------------------------------------------------------------------------------------------------
     20150619   1.0         Michelle Ufford         Open Sourced on GitHub
**********************************************************************************************************/

Set NoCount On;
Set XACT_Abort On;
Set Ansi_Padding On;
Set Ansi_Warnings On;
Set ArithAbort On;
Set Concat_Null_Yields_Null On;
Set Numeric_RoundAbort Off;

Begin

    /* Make sure the global temp tables do not already exist, i.e. failed execution */
    If Exists(Select * From tempdb.sys.tables Where name = '###databaseList')
        Drop Table #databaseList;
        
    If Exists(Select * From tempdb.sys.tables Where name = '##tableList')
        Drop Table tableList;

    /* Declare Temp Tables */
    Create Table ##databaseList
    (
          databaseName  nvarchar(128)
        , processed     bit
    );

    Create Table ##tableList
    (
          databaseName  nvarchar(128)
        , tableName     nvarchar(128)
        , processed     bit
    );

    Insert Into ##databaseList
    Select name As databaseName
        , 0 As processed
    From sys.databases
    Where name = IsNull(@databaseName, name);
    
    While Exists(Select Top 1 databaseName From ##databaseList Where processed = 0)
    Begin
        
        Execute sp_msforeachdb 'Use ?;
            Select name As tableName
            Into ##tableList
            From sys.tables
            Where name = IsNull(@tableName, name);

            Declare @tableName nvarchar(128) = (Select Top 1 tableName From #tableList);

            While Exists(Select Top 1 * From #tableList)
            Begin
                Execute sp_recompile @tableName;
                Delete From #tableList Where tableName = @tableName;
                Select Top 1 @tableName = tableName From #tableList Order By tableName;
            End;

            Drop Table ##tableList;'

    End

    Set NoCount Off;
    Return 0;
End
GO
