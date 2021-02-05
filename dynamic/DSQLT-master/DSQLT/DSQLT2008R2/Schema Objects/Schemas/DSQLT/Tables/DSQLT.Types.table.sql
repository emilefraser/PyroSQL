CREATE TABLE [DSQLT].[Types] (
    [type_id]          INT           NOT NULL,
    [type_name]        VARCHAR (50)  NOT NULL,
    [type_pattern]     VARCHAR (50)  NOT NULL,
    [type_default]     VARCHAR (50)  NOT NULL,
    [type_comparison]  VARCHAR (MAX) NOT NULL,
    [type_concatvalue] VARCHAR (MAX) NOT NULL
);

