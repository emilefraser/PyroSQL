USE tempdb;
GO

--reset demo
DROP TABLE IF EXISTS dbo.child,
                     dbo.parent;
GO

CREATE TABLE dbo.parent
(
    i INT IDENTITY,
	CONSTRAINT pk_parent PRIMARY KEY (i)
);
GO
CREATE TABLE dbo.child
(
    i INT NULL,
	constraint fk_child_parent FOREIGN KEY (i) REFERENCES  dbo.parent(i)
);
GO
DROP TABLE dbo.parent;
GO

ALTER TABLE dbo.child NOCHECK CONSTRAINT  fk_child_parent