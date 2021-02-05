CREATE TABLE [DSQLT].[SourceSearch] (
    [Server]     [sysname]      NULL,
    [Database]   [sysname]      NULL,
    [Schema]     [sysname]      NOT NULL,
    [Program]    [sysname]      NOT NULL,
    [type]       [sysname]      NOT NULL,
    [type_desc]  [sysname]      NULL,
    [definition] NVARCHAR (MAX) NULL
);

