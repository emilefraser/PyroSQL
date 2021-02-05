CREATE TABLE [DSQLT].[CompareResult] (
    [DSQLT_Source]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_Target]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_PrimaryKey]  NVARCHAR (MAX) NOT NULL,
    [DSQLT_ColumnName]  NVARCHAR (258) NOT NULL,
    [DSQLT_SourceValue] NVARCHAR (MAX) NULL,
    [DSQLT_TargetValue] NVARCHAR (MAX) NULL
);

