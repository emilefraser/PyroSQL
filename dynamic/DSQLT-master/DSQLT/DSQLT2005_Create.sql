/*
Bereitstellungsskript für DSQLT_1

Dieser Code wurde von einem Tool generiert.
Änderungen an dieser Datei führen möglicherweise zu falschem Verhalten und gehen verloren, falls
der Code neu generiert wird.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "DSQLT_1"
:setvar DefaultFilePrefix "DSQLT_1"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Überprüfen Sie den SQLCMD-Modus, und deaktivieren Sie die Skriptausführung, wenn der SQLCMD-Modus nicht unterstützt wird.
Um das Skript nach dem Aktivieren des SQLCMD-Modus erneut zu aktivieren, führen Sie folgenden Befehl aus:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'Der SQLCMD-Modus muss aktiviert sein, damit dieses Skript erfolgreich ausgeführt werden kann.';
        SET NOEXEC ON;
    END


GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'$(DatabaseName) wird erstellt....'
GO
CREATE DATABASE [$(DatabaseName)] COLLATE Latin1_General_CI_AS
GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT OFF,
                CURSOR_DEFAULT GLOBAL,
                RECOVERY SIMPLE,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY CHECKSUM,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'Die Datenbankeinstellungen können nicht geändert werden. Diese Einstellungen können nur von Systemadministratoren übernommen werden.';
    END


GO
USE [$(DatabaseName)];


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'disable';


GO
/*
 Vorlage für ein Skript vor der Bereitstellung							
--------------------------------------------------------------------------------------
 Diese Datei enthält SQL-Anweisungen, die vor dem Buildskript ausgeführt werden.	
 Schließen Sie mit der SQLCMD-Syntax eine Datei in das Skript vor der Bereitstellung ein.			
 Beispiel:      :r .\myfile.sql								
 Verweisen Sie mit der SQLCMD-Syntax auf eine Variable im Skript vor der Bereitstellung.		
 Beispiel:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO

GO
PRINT N'[Sample] wird erstellt....';


GO
CREATE SCHEMA [Sample]
    AUTHORIZATION [dbo];


GO
PRINT N'[DSQLT] wird erstellt....';


GO
CREATE SCHEMA [DSQLT]
    AUTHORIZATION [dbo];


GO
PRINT N'[@9] wird erstellt....';


GO
CREATE SCHEMA [@9]
    AUTHORIZATION [dbo];


GO
PRINT N'[@8] wird erstellt....';


GO
CREATE SCHEMA [@8]
    AUTHORIZATION [dbo];


GO
PRINT N'[@7] wird erstellt....';


GO
CREATE SCHEMA [@7]
    AUTHORIZATION [dbo];


GO
PRINT N'[@6] wird erstellt....';


GO
CREATE SCHEMA [@6]
    AUTHORIZATION [dbo];


GO
PRINT N'[@5] wird erstellt....';


GO
CREATE SCHEMA [@5]
    AUTHORIZATION [dbo];


GO
PRINT N'[@4] wird erstellt....';


GO
CREATE SCHEMA [@4]
    AUTHORIZATION [dbo];


GO
PRINT N'[@3] wird erstellt....';


GO
CREATE SCHEMA [@3]
    AUTHORIZATION [dbo];


GO
PRINT N'[@2] wird erstellt....';


GO
CREATE SCHEMA [@2]
    AUTHORIZATION [dbo];


GO
PRINT N'[@1] wird erstellt....';


GO
CREATE SCHEMA [@1]
    AUTHORIZATION [dbo];


GO
PRINT N'[dbo].[@9] wird erstellt....';


GO
CREATE TABLE [dbo].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@8] wird erstellt....';


GO
CREATE TABLE [dbo].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@7] wird erstellt....';


GO
CREATE TABLE [dbo].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@6] wird erstellt....';


GO
CREATE TABLE [dbo].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@5] wird erstellt....';


GO
CREATE TABLE [dbo].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@4] wird erstellt....';


GO
CREATE TABLE [dbo].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@3] wird erstellt....';


GO
CREATE TABLE [dbo].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@2] wird erstellt....';


GO
CREATE TABLE [dbo].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@1] wird erstellt....';


GO
CREATE TABLE [dbo].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@8] wird erstellt....';


GO
CREATE TABLE [@9].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@7] wird erstellt....';


GO
CREATE TABLE [@9].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@6] wird erstellt....';


GO
CREATE TABLE [@9].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@5] wird erstellt....';


GO
CREATE TABLE [@9].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@4] wird erstellt....';


GO
CREATE TABLE [@9].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@3] wird erstellt....';


GO
CREATE TABLE [@9].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@2] wird erstellt....';


GO
CREATE TABLE [@9].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@1] wird erstellt....';


GO
CREATE TABLE [@9].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@9] wird erstellt....';


GO
CREATE TABLE [@9].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@9] wird erstellt....';


GO
CREATE TABLE [@8].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@8] wird erstellt....';


GO
CREATE TABLE [@8].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@7] wird erstellt....';


GO
CREATE TABLE [@8].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@6] wird erstellt....';


GO
CREATE TABLE [@8].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@5] wird erstellt....';


GO
CREATE TABLE [@8].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@4] wird erstellt....';


GO
CREATE TABLE [@8].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@3] wird erstellt....';


GO
CREATE TABLE [@8].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@2] wird erstellt....';


GO
CREATE TABLE [@8].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@1] wird erstellt....';


GO
CREATE TABLE [@8].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@4] wird erstellt....';


GO
CREATE TABLE [@7].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@3] wird erstellt....';


GO
CREATE TABLE [@7].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@2] wird erstellt....';


GO
CREATE TABLE [@7].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@1] wird erstellt....';


GO
CREATE TABLE [@7].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@9] wird erstellt....';


GO
CREATE TABLE [@7].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@8] wird erstellt....';


GO
CREATE TABLE [@7].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@7] wird erstellt....';


GO
CREATE TABLE [@7].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@6] wird erstellt....';


GO
CREATE TABLE [@7].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@5] wird erstellt....';


GO
CREATE TABLE [@7].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@9] wird erstellt....';


GO
CREATE TABLE [@6].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@8] wird erstellt....';


GO
CREATE TABLE [@6].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@7] wird erstellt....';


GO
CREATE TABLE [@6].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@6] wird erstellt....';


GO
CREATE TABLE [@6].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@5] wird erstellt....';


GO
CREATE TABLE [@6].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@4] wird erstellt....';


GO
CREATE TABLE [@6].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@3] wird erstellt....';


GO
CREATE TABLE [@6].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@2] wird erstellt....';


GO
CREATE TABLE [@6].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@1] wird erstellt....';


GO
CREATE TABLE [@6].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@9] wird erstellt....';


GO
CREATE TABLE [@5].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@8] wird erstellt....';


GO
CREATE TABLE [@5].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@7] wird erstellt....';


GO
CREATE TABLE [@5].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@6] wird erstellt....';


GO
CREATE TABLE [@5].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@5] wird erstellt....';


GO
CREATE TABLE [@5].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@4] wird erstellt....';


GO
CREATE TABLE [@5].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@3] wird erstellt....';


GO
CREATE TABLE [@5].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@2] wird erstellt....';


GO
CREATE TABLE [@5].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@1] wird erstellt....';


GO
CREATE TABLE [@5].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@9] wird erstellt....';


GO
CREATE TABLE [@4].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@8] wird erstellt....';


GO
CREATE TABLE [@4].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@7] wird erstellt....';


GO
CREATE TABLE [@4].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@6] wird erstellt....';


GO
CREATE TABLE [@4].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@5] wird erstellt....';


GO
CREATE TABLE [@4].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@4] wird erstellt....';


GO
CREATE TABLE [@4].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@3] wird erstellt....';


GO
CREATE TABLE [@4].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@2] wird erstellt....';


GO
CREATE TABLE [@4].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@1] wird erstellt....';


GO
CREATE TABLE [@4].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@9] wird erstellt....';


GO
CREATE TABLE [@3].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@8] wird erstellt....';


GO
CREATE TABLE [@3].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@7] wird erstellt....';


GO
CREATE TABLE [@3].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@6] wird erstellt....';


GO
CREATE TABLE [@3].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@5] wird erstellt....';


GO
CREATE TABLE [@3].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@4] wird erstellt....';


GO
CREATE TABLE [@3].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@3] wird erstellt....';


GO
CREATE TABLE [@3].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@2] wird erstellt....';


GO
CREATE TABLE [@3].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@1] wird erstellt....';


GO
CREATE TABLE [@3].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@9] wird erstellt....';


GO
CREATE TABLE [@2].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@8] wird erstellt....';


GO
CREATE TABLE [@2].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@7] wird erstellt....';


GO
CREATE TABLE [@2].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@6] wird erstellt....';


GO
CREATE TABLE [@2].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@5] wird erstellt....';


GO
CREATE TABLE [@2].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@4] wird erstellt....';


GO
CREATE TABLE [@2].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@3] wird erstellt....';


GO
CREATE TABLE [@2].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@2] wird erstellt....';


GO
CREATE TABLE [@2].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@1] wird erstellt....';


GO
CREATE TABLE [@2].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@6] wird erstellt....';


GO
CREATE TABLE [@1].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@5] wird erstellt....';


GO
CREATE TABLE [@1].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@4] wird erstellt....';


GO
CREATE TABLE [@1].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@3] wird erstellt....';


GO
CREATE TABLE [@1].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@2] wird erstellt....';


GO
CREATE TABLE [@1].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@1] wird erstellt....';


GO
CREATE TABLE [@1].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@9] wird erstellt....';


GO
CREATE TABLE [@1].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@8] wird erstellt....';


GO
CREATE TABLE [@1].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@7] wird erstellt....';


GO
CREATE TABLE [@1].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[AutoCreatedLocal] wird erstellt....';


GO
CREATE ROUTE [AutoCreatedLocal]
    AUTHORIZATION [dbo]
    WITH ADDRESS = N'LOCAL';


GO
PRINT N'[DSQLT].[isFunc] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Function exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isFunc] (@fn nvarchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@fn) AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isDatabase] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Database exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isDatabase] (@db sysname)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.databases WHERE [name] = @db or QUOTENAME([name]) = @db)
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[Escape] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Cleanup Searchpattern with Escaping [,%,_
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Escape] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN REPLACE(REPLACE(REPLACE(@Text,'[','[[]'),'%','[%]'),'_','[_]')
END
GO
PRINT N'[DSQLT].[CRLF] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	CRLF
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[CRLF]
( )
RETURNS CHAR (2)
AS
BEGIN
	RETURN CHAR(13)+CHAR(10)
END
GO
PRINT N'[DSQLT].[Concat] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Helperfunction for building (comma)separated List
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Concat] (@Value nvarchar(max) ,@Delimiter nvarchar(max), @Result nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN @Result+case when LEN(@Result) = 0 then '' else @Delimiter end + @Value
END
GO
PRINT N'[DSQLT].[SQ] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Single Quote
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[SQ]( )
RETURNS CHAR (1)
AS
BEGIN
	RETURN ''''
END
GO
PRINT N'[DSQLT].[Quote] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Embrace text with quotes. Quotes within text get doubled. Special support for braces as quotes.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Quote]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
		
	SET @Text=@Prefix+REPLACE(@Text,@Quote,@Quote+@Quote)+@Postfix
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[isView] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if View exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isView](@view varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@view) AND type in (N'V'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isTable] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Table exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isTable](@table varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@table) AND type in (N'U'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isSynonym] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Synonym exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isSynonym](@syn varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@syn) AND type in (N'SN'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isQuoted] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Checks, if text is embraced text with quotes. Special support for braces or quotes within text.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isQuoted] (@Text nvarchar(max) ,@Quote nvarchar(max)='[')
RETURNS bit
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	DECLARE @Replace nchar(2) 
	DECLARE @Pos int
	
	-- mindestens 2 Zeichen, sonst nicht gequoted
	IF LEN(@Text) < 2
		RETURN 0
		
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote='('
	--	SET @Quote=')'
	--IF @Quote='<'
	--	SET @Quote='>'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote=')'
	--	SET @Prefix='('
	--IF @Quote='>'
	--	SET @Prefix='<'

	-- Prüfen, ob links und rechts gequoted
	IF SUBSTRING(@Text,1,1) <> @Prefix or SUBSTRING(@Text,LEN(@Text),1) <> @Postfix
		RETURN 0
		
	SET @Text=SUBSTRING(@Text,2,LEN(@Text)-2)
	
	SET @Pos=-1
	WHILE @Pos < LEN(@Text) 
	BEGIN
		SET @Pos=Charindex(@Quote,@Text,@Pos+2)
		-- nix gequoted
		IF @Pos = 0 
			RETURN 1
		-- Quote ist einzeln!
		IF @Pos = LEN(@Text) 
			RETURN 0
		-- nächstes Zeichen nicht identisch??
		IF SUBSTRING(@Text,@Pos,1) <> SUBSTRING(@Text,@Pos+1,1)
			RETURN 0
	END
	-- alles regelgerecht. Der Text könnte gequoted sein.
	RETURN 1
END
GO
PRINT N'[DSQLT].[isProc] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Stored Proc exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isProc](@sp nvarchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@sp) AND type in (N'P', N'PC'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[QuoteSQ] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote text with single quotes.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteSQ] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN [DSQLT].[Quote] (@Text,DSQLT.SQ())
END
GO
PRINT N'[DSQLT].[QuoteSafe] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteSafe]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	-- Wollen wir null oder einen Leerstring wirklich Quoten??
	IF len(isnull(@Text,''))=0
		RETURN ''  -- Nein, wir geben lieber Leeren String zurück.
		
	-- Nur, wenn nicht bereits gequoted
	IF DSQLT.isQuoted(@Text,@Quote)=0
		SET @Text=[DSQLT].[Quote](@Text,@Quote)
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[QuoteName] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote all nameparts of the objectname in text.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteName] (@Text nvarchar(max) ,@Quote nvarchar(max)='[')
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Server sysname
	DECLARE @Database sysname
	DECLARE @Schema sysname
	DECLARE @Object sysname
	
	SET @Server=PARSENAME(@Text,4)
	IF @Server is not null
		SET @Server=DSQLT.QUOTE(@Server,@Quote)+'.'
	ELSE
		SET @Server=''
	
	SET @Database=PARSENAME(@Text,3)
	IF @Database is not null
		SET @Database=DSQLT.QUOTE(@Database,@Quote)+'.'
	ELSE
		IF LEN(@Server) = 0
			SET @Database=''
		ELSE
			SET @Database='.'
			
	SET @Schema=PARSENAME(@Text,2)
	IF @Schema is not null
		SET @Schema=DSQLT.QUOTE(@Schema,@Quote)+'.'
	ELSE
		IF LEN(@Database) = 0
			SET @Schema=''
		ELSE
			SET @Schema='.'
			
	SET @Object=PARSENAME(@Text,1)
	IF @Object is not null
		SET @Object=DSQLT.QUOTE(@Object,@Quote)
	ELSE	-- verrückter Name , hat mehr wie 4 Bestandteile. Quoten wir ihn einfach, falls nötig
		SET @Text=DSQLT.QUOTE(@Text,@Quote)
	
	-- Wenn es ein gültiger Name war, bauen wir ihn aus den Bestandteilen wieder zusammen		
	IF @Object is not null
		SET @Text=@Server+@Database+@Schema+@Object
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[QuoteDQ] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Embrace text with double quote.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteDQ]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'"')
END
GO
PRINT N'[DSQLT].[QuoteSB] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote text with square brackets.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteSB]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'[')
END
GO
PRINT N'[DSQLT].[QuoteNameSB] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote all nameparts of the objectname in text with square brackets.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteNameSB] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN [DSQLT].[QuoteName] (@Text,'[')
END
GO
PRINT N'[DSQLT].[isSchema] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Schema exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isSchema](@schema sysname)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID(@schema) or DSQLT.QuoteSB([name])= @schema)
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[Functions] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Functions
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Functions]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaFunction
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaFunctionQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Function] 
,QUOTENAME(O.name) as [FunctionQ] 
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Digits] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Digits, several Formats
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Digits]
(@from int=0
,@to int=9 )
RETURNS TABLE 
AS
RETURN 
(
WITH Digits(Digit) as
(
select 0 as Digit
UNION ALL
select Digit+1 from Digits where Digit <9
)
select 
Digit
,cast(ltrim(str(Digit)) as nchar(1)) as DigitChar
,cast(Quotename(ltrim(str(Digit))) as nchar(3)) as DigitCharQ
,cast('@'+ltrim(str(Digit)) as nchar(2)) as Parameter
,cast(Quotename('@'+ltrim(str(Digit))) as nchar(4)) as ParameterQ 
from Digits
where Digit between @from and @to
)
GO
PRINT N'[DSQLT].[Databases] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Databases, filtered by @Pattern
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Databases]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Database]
,QUOTENAME(S.name) as DatabaseQ
from sys.databases S 
where S.name LIKE @Pattern
or  QUOTENAME(S.name) LIKE @Pattern)
GO
PRINT N'[DSQLT].[AllSourceContains] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Objects (system objects included) where Sourcecode contains @Pattern
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[AllSourceContains]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[name]+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.[name] as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.all_sql_modules m
join sys.all_objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like @Pattern
)
GO
PRINT N'[DSQLT].[Views] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Tables
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Views]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaView
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaViewQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [View] 
,QUOTENAME(O.name) as [ViewQ] 
from sys.views O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Tables] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Tables
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Tables]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaTable
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaTableQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [Table] 
,QUOTENAME(O.[Name]) as [TableQ] 
from sys.tables O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[SourceContains] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Objects (system objects included) where Sourcecode contains @Pattern
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[SourceContains]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.sql_modules m
join sys.objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like @Pattern
)
GO
PRINT N'[DSQLT].[Schemas] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Schemas
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Schemas]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Schema]
,QUOTENAME(S.name) as SchemaQ
from sys.schemas S 
WHERE (	S.name LIKE @Pattern
	or  QUOTENAME(S.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Procedures] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Procedures
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Procedures]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaProcedure
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProcedureQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Procedure] 
,QUOTENAME(O.name) as [ProcedureQ] 
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'P', N'PC')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Columns] wird erstellt....';


GO
create FUNCTION [DSQLT].[Columns]
(@Object NVARCHAR (MAX)='')
RETURNS @Result TABLE (
	[Name] [sysname] NOT NULL,
	[NameQ] [nvarchar](max) NOT NULL,
	[Column] [sysname] NOT NULL,
	[ColumnQ] [nvarchar](max) NOT NULL,
	[ObjectColumn] [nvarchar](max) NOT NULL,
	[ObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObjectColumn] [nvarchar](max) NOT NULL,
	[SchemaObjectColumnQ] [nvarchar](max) NOT NULL,
	[Type] [sysname] NOT NULL,
	[Type_Id] [tinyint] NOT NULL,
	[is_primary_key] [int] NOT NULL,
	[is_nullable] [bit] NOT NULL,
	[Length] [smallint] NOT NULL,
	[Precision] [tinyint] NOT NULL,
	[Scale] [tinyint] NOT NULL,
	[Order] [int] NOT NULL
)
AS
BEGIN
INSERT @Result
	select top 100 percent
	C.[Name] as [Name]
	,QUOTENAME(C.name) as NameQ
	,C.name as [Column]
	,QUOTENAME(C.name) as ColumnQ
	,O.name+'.'+C.name as ObjectColumn
	,QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as ObjectColumnQ
	,S.name+'.'+O.name+'.'+C.name as SchemaObjectColumn
	,QUOTENAME(S.name)+'.'+QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as SchemaObjectColumnQ
    ,TYPE_NAME(c.system_type_id) AS [Type] 
    ,c.system_type_id AS [Type_Id] 
	,case when Y.index_id is null then 0 else 1 end as is_primary_key
	,C.is_nullable
	,C.max_length as Length
	,C.precision as Precision
	,C.scale as Scale
	,C.column_id as [Order]
	from sys.objects O
	join sys.schemas S on S.schema_id=O.schema_id
	join sys.columns C on C.object_id=O.object_id 
	left outer join sys.indexes I on I.object_id=O.object_id and I.is_primary_key=1
	left outer join sys.index_columns Y ON Y.object_id = I.object_id AND Y.index_id = I.index_id AND Y.column_id = C.column_id
	where QUOTENAME(S.name)+'.'+QUOTENAME(O.name) = DSQLT.QuoteNameSB(@Object)
	order by C.column_id
RETURN
END
GO
PRINT N'[DSQLT].[ColumnList] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Commaseparated List of Columns
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[ColumnList]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END
GO
PRINT N'[Sample].[@Test] wird erstellt....';


GO




CREATE PROC [Sample].[@Test] 
AS
RETURN
BEGIN
select 
S.name+'.'+O.name as SchemaTable
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaTableQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Table] 
,QUOTENAME(O.name) as [TableQ] 
from sys.tables O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.name+'.'+O.name LIKE '%@1%'
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE '%@1%')
END
GO
PRINT N'[Sample].[@ExecCopyTable] wird erstellt....';


GO


CREATE PROCEDURE [Sample].[@ExecCopyTable]
AS RETURN
BEGIN
exec Copy_@1_@2_From_@3
END
GO
PRINT N'[Sample].[@CopyTableTo] wird erstellt....';


GO

CREATE PROCEDURE [Sample].[@CopyTableTo]
AS RETURN
BEGIN
truncate table [@1].[@2] 
insert into [@1].[@2]
select * from [@3].[@1].[@2]
END
GO
PRINT N'[Sample].[@CopyTableFrom] wird erstellt....';


GO
create PROCEDURE [Sample].[@CopyTableFrom]

AS
RETURN
BEGIN
truncate table [@1].[@2] 
insert into [@1].[@2]
select * from [@3].[@1].[@2]
END
GO
PRINT N'[DSQLT].[_replaceParameter] wird erstellt....';


GO

-- ersetzt in einem SQL-Quelltext (@Template) einen Parameter (@Parameter) durch einen Wert (@Value).
-- für anderweitige Verwendung wurde der Parametername mit sysname definiert, obwohl nchar(2) für @0-@9 ausreichen würde.

CREATE PROCEDURE [DSQLT].[_replaceParameter]
@Parameter NVARCHAR (MAX), @Template NVARCHAR (MAX) OUTPUT, @Value NVARCHAR (MAX), @Pos INT OUTPUT
AS
BEGIN
DECLARE @Pattern nvarchar(max)
DECLARE @From int
DECLARE @To int
set @From =0
set @To =0
if @Pos between 1 and LEN(@Template)-1
	BEGIN
	-- 2 zurück
	SET @From=@Pos-2
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'''+@Parameter+'''"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Parameter)  -- Parameter bleibt erhalten Single Quoted
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='""'+@Parameter+'""'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=@Parameter  -- Parameter bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"['+@Parameter+']"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Parameter)  -- Parameter bleibt erhalten mit Klammern
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"('+@Parameter+'"="'+@Parameter+'")'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	-- 1 zurück
	IF @To=0 --and @From>0
		SET @From=@Pos-1
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+'].['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteNameSB(@Value) -- mit Zerlegung in Namensbestandteile, dann Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Value) --  Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='('+@Parameter+'='+@Parameter+')'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'+@Parameter+'"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=''''+@Parameter+''''
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Value) --  Quoten mit '
		END
	END
	-- ab Position
	IF @To=0 --and @From>0
		SET @From=@Pos  
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter+'='+@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
END
if @Value is not null and (@From between 1 and LEN(@Template)) and (@To between 1 and LEN(@Template))
	BEGIN
		Set @Template=STUFF(@Template,@From,@To-@From+1,@Value)
		SET @Pos=@From+len(@Value)-1  -- 13.05.2010. _fillTemplate geht eine Position weiter!!
	END
ELSE
	SET @Pos=0
END
RETURN
GO
PRINT N'[DSQLT].[_generateLinkedserver] wird erstellt....';


GO
CREATE PROC DSQLT._generateLinkedserver(@Server sysname)
as
BEGIN
DECLARE @datasrc varchar(max)
SET @datasrc= @@Servername
EXEC master.dbo.sp_addlinkedserver @server = @Server, @srvproduct=@Server, @provider=N'SQLNCLI', @datasrc=@datasrc
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=@Server,@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc out', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'remote proc transaction promotion', @optvalue=N'true'
END
GO
PRINT N'[DSQLT].[_fillTemplate] wird erstellt....';


GO







-- ersetzt in einem SQL-Quelltext (@Template) die standardisierten Parameter @0 - @9 mit den Werten aus @p0 - @p9. 
-- das Ergebnis wird in @Template zurückgegeben.
-- falls der Parameter @p0 NULL enthält, wird dieser mit dem aktuellen Datenbank-Namen vorbesetzt.
-- dies entspricht der standardmäßigen Verwendung von @0.

CREATE PROCEDURE [DSQLT].[_fillTemplate]
	  @p1 NVARCHAR (MAX)=null
	, @p2 NVARCHAR (MAX)=null
	, @p3 NVARCHAR (MAX)=null
	, @p4 NVARCHAR (MAX)=null
	, @p5 NVARCHAR (MAX)=null
	, @p6 NVARCHAR (MAX)=null
	, @p7 NVARCHAR (MAX)=null
	, @p8 NVARCHAR (MAX)=null
	, @p9 NVARCHAR (MAX)=null
	, @Database NVARCHAR (MAX)=null
	, @Template NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

declare @pos int 
declare @c char(1)
set @pos=0
while @pos >= 0 -- wird innerhalb der Schleife abgebrochen
begin
	set @pos=Charindex('@',@Template,@pos+1)
	if @pos<=0 or @pos>=LEN(@Template)
		break
	
	set @c=SUBSTRING(@Template,@pos+1,1)
	if @c ='0' 	exec DSQLT._replaceParameter '@0',@Template OUTPUT,@Database,@pos OUTPUT
	if @c ='1' 	exec DSQLT._replaceParameter '@1',@Template OUTPUT,@p1,@pos OUTPUT
	if @c ='2' 	exec DSQLT._replaceParameter '@2',@Template OUTPUT,@p2,@pos OUTPUT
	if @c ='3' 	exec DSQLT._replaceParameter '@3',@Template OUTPUT,@p3,@pos OUTPUT
	if @c ='4' 	exec DSQLT._replaceParameter '@4',@Template OUTPUT,@p4,@pos OUTPUT
	if @c ='5' 	exec DSQLT._replaceParameter '@5',@Template OUTPUT,@p5,@pos OUTPUT
	if @c ='6' 	exec DSQLT._replaceParameter '@6',@Template OUTPUT,@p6,@pos OUTPUT
	if @c ='7' 	exec DSQLT._replaceParameter '@7',@Template OUTPUT,@p7,@pos OUTPUT
	if @c ='8' 	exec DSQLT._replaceParameter '@8',@Template OUTPUT,@p8,@pos OUTPUT
	if @c ='9' 	exec DSQLT._replaceParameter '@9',@Template OUTPUT,@p9,@pos OUTPUT
		
	if @pos<=0 or @pos>=LEN(@Template)
		break
end

RETURN
END
GO
PRINT N'[DSQLT].[_fillDatabaseTemplate] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_fillDatabaseTemplate]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

if LEN(@Database)=2 and LEFT(@Database,1)='@' and ISNUMERIC(right(@Database,1))=1  -- einfache Parameter
	exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=null,@Template=@Database OUTPUT

RETURN
END
GO
PRINT N'[DSQLT].[_execSQL] wird erstellt....';


GO





-- führt eine Stored Proc in einer anderen Datenbank aus.
-- mit dem optionalen Parameter @Print kann der generierte Code ausgegeben anstatt ausgeführt werden.

CREATE PROCEDURE [DSQLT].[_execSQL] 
	@Database sysname 
	, @SQL NVARCHAR (MAX)=null
	, @Print bit=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
Set @SQL='exec '+DSQLT.QuoteSB(@Database)+'..sp_executesql N'+DSQLT.QuoteSQ(@SQL)

IF @Print=0
	exec (@SQL)
	
IF @Print=1 
	print (@SQL)

RETURN 0
END
GO
PRINT N'[DSQLT].[_error] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_error] 
	@Msg nvarchar(max)=''
AS
BEGIN
SET @Msg='DSQLT ERROR : '+@Msg
print @Msg
END
GO
PRINT N'[DSQLT].[_doTemplate] wird erstellt....';


GO



CREATE PROCEDURE [DSQLT].[_doTemplate]
	@Database sysname=null,
	@Template NVARCHAR (MAX),
	@Print bit=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
if @Database=DB_NAME() -- kein Datenbankwechsel nötig
	BEGIN
	IF @Print=0 
			exec (@Template)  
	IF @Print=1 
			print (@Template)
	END
ELSE
		exec DSQLT._execSQL @Database,@Template,@Print   -- ausführen in der Zieldatenbank
RETURN 0
END
GO
PRINT N'[DSQLT].[License] wird erstellt....';


GO
CREATE PROC DSQLT.License
as 
BEGIN
print
'
The DSQLT-framework is developed by Henrik Bauer and published under Ms-PL at CodePlex  http://dsqlt.codeplex.com.

'
print
'
Microsoft Public License (Ms-PL)

This license governs use of the accompanying software. If you use the software, you accept this license. If you do not accept the license, do not use the software.

1. Definitions

The terms "reproduce," "reproduction," "derivative works," and "distribution" have the same meaning here as under U.S. copyright law.

A "contribution" is the original software, or any additions or changes to the software.

A "contributor" is any person that distributes its contribution under this license.

"Licensed patents" are a contributor''s patent claims that read directly on its contribution.

2. Grant of Rights

(A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.

(B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.

3. Conditions and Limitations

(A) No Trademark License- This license does not grant you rights to use any contributors'' name, logo, or trademarks.

(B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.

(C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.

(D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.

(E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.   
 
'
END
GO
PRINT N'[DSQLT].[_getTemplate] wird erstellt....';


GO



CREATE proc [DSQLT].[_getTemplate]
	@DSQLTProc nvarchar(max)
	, @Template nvarchar(max) OUTPUT
as
BEGIN
declare @sql nvarchar(max)
declare @schema sysname
declare @begin int
declare @end int
declare @textzeilen nvarchar(max)
set @textzeilen='' 
-- zerlege Name in Schema und Objektname
SET @schema=PARSENAME(@DSQLTProc,2)
SET @DSQLTProc=PARSENAME(@DSQLTProc,1)
-- Beginnt per Konvention mit @ 
IF left(@DSQLTProc,1) <> '@' 
	SET @DSQLTProc = '@'+@DSQLTProc
-- Ist im Schema DSQLT, falls keines angegeben
IF @schema is null
	SET @schema = 'DSQLT'
-- Namen wieder zusammenbasteln
SET @DSQLTProc = @schema+'.'+@DSQLTProc
IF DSQLT.isProc(@DSQLTProc)=1
	BEGIN
	-- temporäre Tabelle, je Zeile Quelltext eine Tabellenzeile
	create table #t1 (z int identity(1,1), txt varchar(1000))
	-- Quelltext der prozedur in Tabelle einfügen
	insert into #t1 exec sp_helptext @DSQLTProc
	-- Kommentare strippen
	update #t1 set txt = left(txt,case when Charindex('--',txt)=0 then len(txt) else Charindex('--',txt)-1 end)
	-- Blanks links, rechts sowie Tabs und CR LF entfernen
	update #t1 set txt = ltrim(rtrim(replace(replace(replace(txt,CHAR(9),''),CHAR(10),''),CHAR(13),'')))
	-- leere zeilen löschen
	delete from #t1 where LEN(txt)=0 or txt is null
	-- erstes BEGIN
	select top 1 @begin=z from #t1 where txt = 'BEGIN' order by z
	-- und letztes END ermitteln
	select top 1 @end=z from #t1 where txt = 'END' order by z desc
	-- dazwischen ist unser Quelletext. Aufsammeln und Zeileumbruch ergänzen
	select @textzeilen=@textzeilen+txt+char(13)+char(10) from #t1 where z between @begin+1 and @end-1
	-- aufräumen
	drop table #t1
	-- Output Parameter setzen
	Set @Template= @textzeilen
	END
ELSE
	BEGIN
	-- Wenn noch in der Datenbank DSQLT gesucht wurde
	-- aber das Template im Schema DSQLT sein soll, dann nochmals in der Datenbank DSQLT suchen
		IF DB_NAME() <> 'DSQLT' and @schema = 'DSQLT'  	
			BEGIN
			exec [DSQLT].[DSQLT].[_getTemplate] @DSQLTProc, @Template OUTPUT
			END
		ELSE
			BEGIN
			exec DSQLT._error 'Template nicht gefunden'
			END
	END
RETURN
END
GO
PRINT N'[Sample].[@CopyTableContentTo] wird erstellt....';


GO



CREATE PROCEDURE [Sample].[@CopyTableContentTo]
	@Database sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
AS
	Declare @3 nvarchar(max)
	Declare @4 nvarchar(max)
	set @3 = DSQLT.ColumnList(@Schema+'.'+@Table)
	set @4 = DB_NAME()
	exec DSQLT.[Execute] '[Sample].@CopyTableContent',@Schema,@Table,@3,@4,@Database=@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END
GO
PRINT N'[Sample].[@CopyTableContentFrom] wird erstellt....';


GO



CREATE PROCEDURE [Sample].[@CopyTableContentFrom]
	@Schema sysname
	,@Table sysname
	,@Database sysname=null
	,@Print int=0
AS
	if @Database is null SET @Database=DB_NAME()
	Declare @3 nvarchar(max)
	set @3= DSQLT.ColumnList(@Schema+'.'+@Table)
	exec DSQLT.[Execute] '[Sample].[@CopyTableContentFrom]',@Schema,@Table,@3,@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END
GO
PRINT N'[Sample].[@@CopyTableContentTo] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@@CopyTableContentTo]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname=null
	,@Print bit = 0
AS
	Declare @Source nvarchar(max)
	set @Source = DB_NAME()
	exec DSQLT.iterate '[Sample].[@CopyTableContentTo]',@Cursor,@Source,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[Sample].[@@CopyTableContentFrom] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@@CopyTableContentFrom]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname=null
	,@Print bit = 0
AS
	if @Database is null SET @Database=DB_NAME()
	exec DSQLT.iterate '[Sample].[@CopyTableContentFrom]',@Cursor,@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@CopyTable] wird erstellt....';


GO







CREATE PROCEDURE [DSQLT].[@@CopyTable]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyTable',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@CopyProcedure] wird erstellt....';


GO







create PROCEDURE [DSQLT].[@@CopyProcedure]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyProcedure',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@CopyFunction] wird erstellt....';


GO






CREATE PROCEDURE [DSQLT].[@@CopyFunction]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyFunction',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@Print1Parameter] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@Print1Parameter]
	  @p1 NVARCHAR (MAX)=null
	, @Print bit = 0
AS
exec DSQLT.[Execute] '@Print1Parameter' ,@p1,@Print=@Print
RETURN 0
BEGIN
	if '@1' = '"@1"' 	print '@1'
END
GO
PRINT N'[DSQLT].[@isView] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@isView]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@View sysname -- View
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isView',@Schema,@View,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]')  AND type in (N'V'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@isTable] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@isTable]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Table sysname -- Tabelle
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isTable',@Schema,@Table,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'U'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@isSynonym] wird erstellt....';


GO


CREATE PROCEDURE [DSQLT].[@isSynonym]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Synonym sysname -- Synonym 
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isSynonym',@Schema,@Synonym,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'SN'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@isSchema] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@isSchema]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isSchema',@Schema,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID('@1') or QUOTENAME([name])= '[@1]')
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@isProc] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@isProc]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Table sysname -- Tabelle
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isProc',@Schema,@Table,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'P', N'PC'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@isFunc] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@isFunc]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Table sysname -- Tabelle
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
DECLARE @Template varchar(max)
-- Template (unten zwischen BEGIN und END) holen
exec DSQLT.[Execute] '@isFunc',@Schema,@Table,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result 
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@getObjectDefinition] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@getObjectDefinition]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Object sysname -- Object
,@Template nvarchar(max) output
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result nvarchar(max))
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
exec DSQLT.[Execute] '@getObjectDefinition',@Schema,@Object,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable 
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Template=result from @ResultTable
RETURN 
BEGIN
	Select OBJECT_DEFINITION(OBJECT_ID('[@1].[@2]'))
END
GO
PRINT N'[DSQLT].[@GenerateTable] wird erstellt....';


GO


CREATE PROC [DSQLT].[@GenerateTable] 
	@Database sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
as
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
GO
PRINT N'[DSQLT].[@GenerateSchema] wird erstellt....';


GO


CREATE Proc [DSQLT].[@GenerateSchema]
	@Database sysname
	, @Schema sysname
	, @Print int =0
as
exec DSQLT.[Execute] '@GenerateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
exec DSQLT.DSQLT._generateSchema '[@0]','[@1]'
END
GO
PRINT N'[DSQLT].[@GenerateDatabase] wird erstellt....';


GO





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
GO
PRINT N'[DSQLT].[@DropTable] wird erstellt....';


GO



CREATE PROC [DSQLT].[@DropTable] 
	@Database sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TABLE [@1].[@2]
END
GO
PRINT N'[DSQLT].[@DropProcedure] wird erstellt....';


GO



CREATE PROC [DSQLT].[@DropProcedure] 
	@Database sysname
	,@Schema sysname
	,@Procedure sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropProcedure',@Schema,@Procedure,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP PROCEDURE [@1].[@2]
END
GO
PRINT N'[DSQLT].[@DropFunction] wird erstellt....';


GO


CREATE PROC [DSQLT].[@DropFunction] 
	@Database sysname
	,@Schema sysname
	,@Function sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropFunction',@Schema,@Function,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP FUNCTION [@1].[@2]
END
GO
PRINT N'[DSQLT].[@DropDatabase] wird erstellt....';


GO

CREATE PROC [DSQLT].[@DropDatabase] 
	 @Database sysname =null
	, @Print bit = 0
AS
exec DSQLT.[Execute] '@DropDatabase' ,@p1=@Database,@Print=@Print
RETURN 0
BEGIN
DROP DATABASE [@1]
END
GO
PRINT N'[DSQLT].[@CreateSchema] wird erstellt....';


GO




CREATE Proc [DSQLT].[@CreateSchema]
	@Database sysname
	, @Schema sysname
	, @Print int =0
as
exec DSQLT.[Execute] '@CreateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
DECLARE @Result int
exec @Result=DSQLT.DSQLT.[@isSchema] '[@0]','[@1]'
IF @Result=0
	BEGIN
	declare @Template nvarchar(max)
	SET @Template ='CREATE SCHEMA [@1]'
	exec (@Template)
	END
END
GO
PRINT N'[DSQLT].[@CopyTable] wird erstellt....';


GO


CREATE PROC [DSQLT].[@CopyTable] 
	@TargetDB sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
as
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyTable',@Schema,@Table,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isTable] '@3','@1','@2'
if @rc=1  -- ja
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isTable] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropTable] '@0','@1','@2'
	-- dann Objekt erzeugen
	Select * 
	INTO [@0].[@1].[@2]
	from [@3].[@1].[@2]
	END
END
GO
PRINT N'[DSQLT].[@CopyProcedure] wird erstellt....';


GO






CREATE PROC [DSQLT].[@CopyProcedure] 
	@TargetDB sysname
	,@Schema sysname
	,@Procedure sysname
	,@Print int=0
as
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyProcedure',@Schema,@Procedure,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isProc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isProc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropProcedure] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	END
END
GO
PRINT N'[DSQLT].[@CopyFunction] wird erstellt....';


GO

CREATE PROC [DSQLT].[@CopyFunction] 
	@TargetDB sysname
	,@Schema sysname
	,@Function sysname
	,@Print int=0
as
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyFunction',@Schema,@Function,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isFunc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isFunc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropFunction] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	END
END
GO
PRINT N'[DSQLT].[@@PrintParameter] wird erstellt....';


GO



CREATE PROCEDURE [DSQLT].[@@PrintParameter]
	  @Cursor CURSOR VARYING OUTPUT 
	, @p1 NVARCHAR (MAX)=null
	, @p2 NVARCHAR (MAX)=null
	, @p3 NVARCHAR (MAX)=null
	, @p4 NVARCHAR (MAX)=null
	, @p5 NVARCHAR (MAX)=null
	, @p6 NVARCHAR (MAX)=null
	, @p7 NVARCHAR (MAX)=null
	, @p8 NVARCHAR (MAX)=null
	, @p9 NVARCHAR (MAX)=null
	, @Database sysname =null
	, @Print bit = 0
AS
	exec DSQLT.iterate '@PrintParameter',@Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@GenerateTable] wird erstellt....';


GO




CREATE PROCEDURE [DSQLT].[@@GenerateTable]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
	exec DSQLT.iterate '@GenerateTable',@Cursor,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@GenerateSchema] wird erstellt....';


GO





CREATE PROCEDURE [DSQLT].[@@GenerateSchema]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
	exec DSQLT.iterate '@GenerateSchema',@Cursor,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[_iterateTemplate] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[_iterateTemplate]
@Cursor CURSOR VARYING OUTPUT, @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX)=null, @Template NVARCHAR (MAX)=null OUTPUT, @Create NVARCHAR (MAX)=null, @Once BIT=0, @Print BIT=0
AS
Begin
DECLARE @TemplateConcat nvarchar(max)
DECLARE @Temp nvarchar(max)
DECLARE @TempCreate nvarchar(max)
DECLARE @TempDatabase nvarchar(max)
DECLARE @OrgDatabase nvarchar(max)
DECLARE @c1 nvarchar(max)
DECLARE @c2 nvarchar(max)
DECLARE @c3 nvarchar(max) 
DECLARE @c4 nvarchar(max)
DECLARE @c5 nvarchar(max)
DECLARE @c6 nvarchar(max)
DECLARE @c7 nvarchar(max)
DECLARE @c8 nvarchar(max)
DECLARE @c9 nvarchar(max)
DECLARE	@Count int

set @TemplateConcat ='' 
set @Temp  ='' 
set @TempCreate  ='' 
set	@Count = 0
set @OrgDatabase=@Database

open @Cursor
while (1=1)
begin
	if @count=0
	BEGIN  -- feststellen der Anzahl Spalten, die vom Cursor zurückgeliefert werden
		begin try 
			set @count=1
			fetch first from @Cursor into @c1
			SET @c2=@p1
			SET @c3=@p2
			SET @c4=@p3
			SET @c5=@p4
			SET @c6=@p5
			SET @c7=@p6
			SET @c8=@p7
			SET @c9=@p8
			continue
		end try 
		begin catch
			set @count=2
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2
			SET @c3=@p1
			SET @c4=@p2
			SET @c5=@p3
			SET @c6=@p4
			SET @c7=@p5
			SET @c8=@p6
			SET @c9=@p7
			continue
		end try 
		begin catch
			set @count=3
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3
			SET @c4=@p1
			SET @c5=@p2
			SET @c6=@p3
			SET @c7=@p4
			SET @c8=@p5
			SET @c9=@p6
			continue
		end try 
		begin catch
			set @count=4
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4
			SET @c5=@p1
			SET @c6=@p2
			SET @c7=@p3
			SET @c8=@p4
			SET @c9=@p5
			continue
		end try 
		begin catch
			set @count=5
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5
			SET @c6=@p1
			SET @c7=@p2
			SET @c8=@p3
			SET @c9=@p4
			continue
		end try 
		begin catch
			set @count=6
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
			SET @c7=@p1
			SET @c8=@p2
			SET @c9=@p3
			continue
		end try 
		begin catch
			set @count=7
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
			SET @c8=@p1
			SET @c9=@p2
			continue
		end try 
		begin catch
			set @count=8
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
			SET @c9=@p1
			continue
		end try 
		begin catch
			set @count=9
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
			continue
		end try 
		begin catch
		print @count
			-- Spaltenanzahl nicht zwischen 1 und 9
		end catch
		Break  -- erfolglos
	END
	IF (@@FETCH_STATUS <> 0) break  -- alle Datensätze geholt
	
	set @Database=@OrgDatabase
		-- Parameterersetzung für Datenbanknamen
	exec DSQLT._fillDatabaseTemplate  @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database=@Database OUTPUT

	SET @Temp=@Template 
	-- Prozedurrumpf mit DDL umfassen, falls Create 
	-- wichtig: generell Parameterersetzung wie bei Template
	if @Create is not null and (@Once=0 or @TempCreate='')  -- bei once=0 ODER beim ersten Mal
		BEGIN
		SET @TempDatabase=@Database
		SET @TempCreate=@Create 
		exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@TempCreate OUTPUT
		if @Once=0	-- dann wird je Iteration eine Stored Proc generiert
			exec DSQLT._addCreateStub @Temp OUTPUT,@Database,@TempCreate
		END
		
	exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@Temp OUTPUT

	-- ausführen oder verketten
	IF @Once=0  -- ausführen / drucken
		exec DSQLT._doTemplate @Database,@Temp,@Print
		
	-- immer verketten, stört nicht
	SET @TemplateConcat=@TemplateConcat+@Temp+DSQLT.CRLF()

	IF @Count = 1 fetch next from @Cursor into @c1
	IF @Count = 2 fetch next from @Cursor into @c1,@c2
	IF @Count = 3 fetch next from @Cursor into @c1,@c2,@c3
	IF @Count = 4 fetch next from @Cursor into @c1,@c2,@c3,@c4
	IF @Count = 5 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5
	IF @Count = 6 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
	IF @Count = 7 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
	IF @Count = 8 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
	IF @Count = 9 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
end
close @Cursor
deallocate @Cursor

--  ausführen, falls einmalig
if @Once=1
	BEGIN
	IF @Create is not null  -- einmalig Prozedurrumpf
		exec DSQLT._addCreateStub @TemplateConcat OUTPUT,@TempDatabase,@TempCreate
	exec DSQLT._doTemplate @TempDatabase,@TemplateConcat,@Print
	END

-- Rückgabe der Verkettung
SET @Template =@TemplateConcat
	
end
GO
PRINT N'[DSQLT].[_generateSchema] wird erstellt....';


GO










CREATE PROCEDURE [DSQLT].[_generateSchema]
@Database [sysname], @Schema [sysname], @Print BIT=0
AS
BEGIN
-- Schema erzeugen, falls noch nicht existiert
DECLARE @Result int
exec @Result=DSQLT.[@isSchema] @Database,@Schema
IF @Result=0
	exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- alle Tabellen erzeugen
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select @Schema,ParameterQ from [DSQLT].[Digits] (1,9)
exec DSQLT.[@@GenerateTable] @Cursor,@Database=@Database,@Print=@Print
	
END
GO
PRINT N'[DSQLT].[_generateDSQLTStub] wird erstellt....';


GO

create Proc [DSQLT].[_generateDSQLTStub]
	@Schema sysname
	,@Procedure sysname
	,@Database sysname
	,@Print bit = 0
	,@Iterate bit = 0
as
BEGIN
declare @Stub varchar(max)
declare @Template varchar(max)
declare @ErrorMsg varchar(max)
SET @Stub='@@2'
SET @Template=''
if @Iterate=1 set @Stub='@'+@Stub
SET @ErrorMsg ='Template @1.'+@Stub+' nicht gefunden'

declare @rc int
-- Prüfen, ob Zielobjekt existiert
exec @rc=DSQLT.[@isProc] @Database,@Schema,@Procedure
if @rc=0  -- nein,dann Definition für Stub holen
	exec [DSQLT].[@getObjectDefinition] null,'@1',@Stub,@Template output
else 
	exec DSQLT._error 'Ziel existiert bereits'
-- falls geklappt,dann Objekt erzeugen
if @Template is not null
	exec DSQLT.[Execute] null,@Schema,@Procedure, @Database=@Database,@Template=@Template,@Print=@Print
else 
	exec DSQLT._error @ErrorMsg
END
GO
PRINT N'[DSQLT].[_generateDSQLT] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[_generateDSQLT]
@Database [sysname], @Print INT=0
AS
BEGIN
DECLARE @SourceDB sysname
DECLARE @Schema sysname

SET @SourceDB =DB_NAME()
SET @Schema ='DSQLT'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Func iterieren
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Function],@SourceDB from [DSQLT].Functions(@Schema+'.%') 
exec [DSQLT].[@@CopyFunction] @Cursor,@Database=@Database,@Print=@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB from [DSQLT].[Procedures](@Schema+'.%') 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

set @Schema ='@1'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB from [DSQLT].[Procedures](@Schema+'.%') 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

END
GO
PRINT N'[DSQLT].[_generateDatabase] wird erstellt....';


GO


CREATE Proc [DSQLT].[_generateDatabase]
	@Database sysname
	,@Print int = 0
as
BEGIN
-- nur bei den "eigenen" Parameter-Datenbanken ggf. löschen
if DSQLT.QuoteNameSB(@Database) in (select ParameterQ from [DSQLT].[Digits](0,9))  
	IF DSQLT.isDatabase(@Database)=1  -- wenn schon existiert, dann löschen
		exec DSQLT.[@DropDatabase] @Database,@Print=@Print
		
-- wenn noch nicht existiert, dann erzeugen		
IF DSQLT.isDatabase(@Database)=0  
	exec DSQLT.[@GenerateDatabase] @Database,@Print=@Print

-- die nach Parameter benannten Tabellen im Schema dbo erzeugen	
exec DSQLT.[@GenerateSchema] @Database,'dbo',@Print=@Print

-- die nach Parameter benannten Schemas und Tabellen erzeugen	
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ParameterQ from [DSQLT].[Digits] (1,9)
exec DSQLT.[@@GenerateSchema] @Cursor,@Database=@Database,@Print=@Print

---- das Schema DSQLT mit Functions und Procedures erzeugen
exec DSQLT._generateDSQLT @Database,@Print=@Print

END
GO
PRINT N'[DSQLT].[_addCreateStub] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[_addCreateStub]
@Template NVARCHAR (MAX) OUTPUT, @Database NVARCHAR (MAX), @Create NVARCHAR (MAX), @CreateParam NVARCHAR (MAX)=''
AS
BEGIN
declare	@Command NVARCHAR (max)
declare	@Schema NVARCHAR (max) 
declare	@Object NVARCHAR (max)
declare @rc int
-- Namen in Schema und Objekt zerlegen
set	@Command ='CREATE'
set @Schema=isnull(PARSENAME(@Create,2),'dbo')
set @Object=PARSENAME(@Create,1)
-- Prüfen, ob Zielobjekt existiert
exec @rc=DSQLT.[@isProc] @Database,@Schema,@Object
if @rc=1  
	SET @Command='ALTER'

-- DDL Vorspann + Name
SET @Command=@Command+' PROCEDURE ' + @Create+[DSQLT].[CRLF]()
-- Parameter
IF LEN(@CreateParam) > 0
	SET @Command=@Command+@CreateParam+[DSQLT].[CRLF]()
-- Body
SET @Template=@Command+
 + 'AS'+[DSQLT].[CRLF]()
 + 'BEGIN'+[DSQLT].[CRLF]()
 + @Template+[DSQLT].[CRLF]()
 + 'END'+[DSQLT].[CRLF]()
RETURN
END
GO
PRINT N'[DSQLT].[Iterate] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[Iterate]
@DSQLTProc NVARCHAR (MAX)=null, @Cursor CURSOR VARYING OUTPUT, @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Template NVARCHAR (MAX)=null OUTPUT, @Create NVARCHAR (MAX)=null, @Once BIT=0, @Print BIT=0
AS
Begin
SET NOCOUNT ON
if @Database is null
	SET @Database=DB_NAME()

-- Template holen
if @DSQLTProc is not null  -- es kann auch ein Template direkt übergeben werden
	exec DSQLT._getTemplate @DSQLTProc, @Template OUTPUT
	
-- Template iterieren 
exec DSQLT._iterateTemplate @Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template OUTPUT,@Create,@Once,@Print

end
GO
PRINT N'[DSQLT].[Execute] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[Execute]
@DSQLTProc NVARCHAR (MAX), @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Template NVARCHAR (MAX)=null OUTPUT, @Create NVARCHAR (MAX)=null, @CreateParam NVARCHAR (MAX)='', @Print BIT=0
AS
BEGIN
SET NOCOUNT ON
--if @Database is null
--	SET @Database=DB_NAME()
exec DSQLT._fillDatabaseTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database OUTPUT

-- Template holen	
if @DSQLTProc is not null  -- es kann auch ein Template direkt übergeben werden
	exec DSQLT._getTemplate @DSQLTProc, @Template OUTPUT
	
if @Create is not null 
	BEGIN
	exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template=@Create OUTPUT
	exec DSQLT._addCreateStub @Template OUTPUT,@Database,@Create,@CreateParam
	END

-- Parameter ersetzen
exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template=@Template OUTPUT

-- ausführen/drucken
exec DSQLT._doTemplate @Database,@Template,@Print
RETURN 0
END
GO
PRINT N'[DSQLT].[@PrintParameter] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@PrintParameter]
	  @p1 NVARCHAR (MAX)=null
	, @p2 NVARCHAR (MAX)=null
	, @p3 NVARCHAR (MAX)=null
	, @p4 NVARCHAR (MAX)=null
	, @p5 NVARCHAR (MAX)=null
	, @p6 NVARCHAR (MAX)=null
	, @p7 NVARCHAR (MAX)=null
	, @p8 NVARCHAR (MAX)=null
	, @p9 NVARCHAR (MAX)=null
	, @Database sysname =null
	, @Print bit = 0
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
GO
PRINT N'[@1].[@@@2] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Template for iterate Stub.
--
--------------------------------------------------------
CREATE PROCEDURE [@1].[@@@2]
	  @Cursor CURSOR VARYING OUTPUT 
	, @p1 NVARCHAR (MAX)=null
	, @p2 NVARCHAR (MAX)=null
	, @p3 NVARCHAR (MAX)=null
	, @p4 NVARCHAR (MAX)=null
	, @p5 NVARCHAR (MAX)=null
	, @p6 NVARCHAR (MAX)=null
	, @p7 NVARCHAR (MAX)=null
	, @p8 NVARCHAR (MAX)=null
	, @p9 NVARCHAR (MAX)=null
	, @Database sysname =null
	, @Print bit = 0
AS
exec DSQLT.iterate '@1.@@2' ,@Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[@1].[@@2] wird erstellt....';


GO
--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Template for DSQLT Stub.
--
--------------------------------------------------------
CREATE PROCEDURE [@1].[@@2]
	  @p1 NVARCHAR (MAX)=null
	, @p2 NVARCHAR (MAX)=null
	, @p3 NVARCHAR (MAX)=null
	, @p4 NVARCHAR (MAX)=null
	, @p5 NVARCHAR (MAX)=null
	, @p6 NVARCHAR (MAX)=null
	, @p7 NVARCHAR (MAX)=null
	, @p8 NVARCHAR (MAX)=null
	, @p9 NVARCHAR (MAX)=null
	, @Database sysname =null
	, @Print bit = 0
AS
exec DSQLT.[Execute] '@1.@@2' ,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
print 0
END
GO
PRINT N'Berechtigung wird erstellt....';


GO
GRANT CONNECT TO [dbo]
    AS [dbo];


GO
/*
Vorlage für ein Skript nach der Bereitstellung							
--------------------------------------------------------------------------------------
 Diese Datei enthält SQL-Anweisungen, die an das Buildskript angefügt werden.		
 Schließen Sie mit der SQLCMD-Syntax eine Datei in das Skript nach der Bereitstellung ein.			
 Beispiel:      :r .\myfile.sql								
 Verweisen Sie mit der SQLCMD-Syntax auf eine Variable im Skript nach der Bereitstellung.		
 Beispiel:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET MULTI_USER 
    WITH ROLLBACK IMMEDIATE;


GO
PRINT N'Update abgeschlossen.';


GO
