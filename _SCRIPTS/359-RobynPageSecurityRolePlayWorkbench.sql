/*
    Contents
    --------
Preamble
SQL Injection
Other Security Risks
Managing access to Database Objects
The Test-Database Build Script
Reassigning those 'Deny' roles
Taking out the 'permission' donkey work
The Test harness

    Preamble
    --------

SQL Server Security is sometimes rather a blind spot to application 
developers. This has been widely illustrated by the success of very 
simple attacks on database-driven websites, which would have been
prevented by even moderate security measures

In this workbench we will present two slightly different
security models for a database. One of these uses roles to deny access
to tables and views, and the other relies on withholding permissions
to all objects except the stored procedures that make up the 
application-interfece.

So what are these formas of attack on databases that have been so 
successful? Well, nothing very clever, just ways of testing whether 
any real security has been put in place. SQL Injection attacks are just
one example of the many ways of gaining access to data with  malicious 
intent.

    SQL Injection
    -------------

It is impossible, purely from the database layer of an application 
alone, to prevent SQL injection attacks happening, but you can render 
them harmless as long as you can manage the Usernames that the 
application has, in order to access the database. If you are accustomed 
to give you application logins DBO rights in your database, then it is 
time to tighten security

SQL Injection comes through the failure of the application programmer
to filter the input from the user to 'escape' or otherwise change
SQL String-delimiters in input from the user. 

So, when a user types in CM5 4RS for his postcode, then the 
application programmer might take it into his, or her, head to 
construct, on the fly, the SQL String...*/

insert into address (customer_id,postcode) values (2421,'CM5 4RS')

/* then it is the work of a moment for a hacker to type the following 
into the postcode field of the application*/

--  CM5 4RS') Select * from customer select ('

--  which is then automatically converted into:

insert into address (customer_id,postcode) values (2421,'CM5 4RS') 
Select * from customer 
select ('')
/*
with obvious results, and no apparent error.

Of course, if the application programmer has remembered to 'escape' 
the string delimiter "'", then it will probably just trigger a rule 
error, (see the Data Validation Workbench for details,
http://www.simple-talk.com/sql/learn-sql-server/robyn-pages-sql-server-data-validation-workbench/)
*/

insert into address (customer_id,postcode) values (2421,'CM5 4RS'') 
Select * from customer 
select (''')
/* 
...but any DBA will be wondering how on earth you would have left
the customer table accessible if it has personal information in it

   Other security risks
   --------------------

No password at all!
    The worst risk of all is the one of having an SA Login with no
    password. You may think this never happens, but I came across
    a site recently where exactly this was in place in a production
    manufacturing application, installed by a commercial software
    company, on an intranet. Similar problems happen when obvious 
    passwords are in use and never changed.

Nicking the database
    Sometimes one comes across a website using a database such as
    SQLite, where the database file is actually kept in the document
    root of /WWW. It can be downloaded and read with a simple 
    HTTP request - and it is in plain text. 

Exposed access credentials! 
    This simply means leaving the user ID and password in an 'INCLUDE'
    file or embedded in a code file which can be downloaded by a user. 
    One should always use integrated security wherever    possible, 
    since it does not require any separate authentication of 
    the user. It is plain silly to leave the INCLUDE file within the 
    document root of /WWW in a web application as it can be gotten
    with a simple HTTP Request. The funniest story I heard was of the
    occasion that a spammer left a user_ID and password to his FTP site
    in code in the body of the Spam he sent out. The FTP site was soon
    empty!

Exposed error reporting
    This just means that if an attacker manages to penetrate the
    database by means of SQL Injection, he can gain a great deal of
    information by means of reading error information that is intended
    for the developer. Error Debug Information must be logged (we 
    use Emails to send error information) and not shown to the end user.

Poor Housekeeping
    Even where DBAs have taken a lot of trouble with security, it is 
    sometimes possible to find database backups, table-backups or other
    such files lying around, with commercial or personal data in them.

In this workshop we will concentrate on the means to prevent access
to sensitive information within the database itself, from a user
connecting with an application login.

    Managing access to database objects
    -----------------------------------

We'll be experimenting with two obvious techniques:

1/ Use the DenyDataReader and DenyDataWriter Database roles and assign 
these roles to the users of the application

Advantage:    difficult to defeat
Disadvantage: no access to views or table functions by the application

2/ give access-permissions only to the views and stored procedures that
are to be used by the application.

Advantage:    access to views as well as procedures to the application
Disadvantage: can be compromised where complex security model is in place 

Preventing any damage through SQL Injection is a relatively simple 
matter. You should not allow access to the base tables by the 
application. All database access should be through a set of stored
procedures. This will often cause emotional scenes amongst the 
programmers, but the result will be a secure database. There are
occasional instances where the programmers can be justified in 
objecting, such as when a widget is directly bound to a table,
in which case the second model can be used.

So, let's set up a sample database and try out these techniques

    The Test-Database Build Script
    ------------------------------

Firstly create a database called SecurityWorkbench. Then... */

--add a login for the application
EXEC master.dbo.sp_addlogin @loginame = N'Workbench', 
        @passwd = 'mypassword', 
        @defdb = N'SecurityWorkbench', 
        @deflanguage = N'us_english'

EXEC dbo.sp_grantdbaccess 
    @loginame = N'Workbench', @name_in_db = N'Workbench'
GO


--and now we will create a sample data table, just the thing
--that the hacker is after:

--drop table customer
CREATE TABLE [dbo].[Customer](
    [Customer_ID] [int] IDENTITY(1,1) NOT NULL,
    [Firstname] [varchar](50) NULL,
    [Surname] [varchar](50) NOT NULL,
    [Password] [varchar](50) NULL,
    [User_ID] [varchar](20) NOT NULL,
    [CreditCardNo] [char](16) NULL,
    [SortCode] [varchar](20) NULL,
    [AccountNo] [varchar](20) NULL,
    [InsertionDate] [datetime] NOT NULL 
        CONSTRAINT [DF_Customer_InsertionDate]  
        DEFAULT (getdate())
) ON [PRIMARY]


/* Now we create a stored procedure that checks the User ID and 
password of the user, so it is unnecessary to expose the information
outside the database */

CREATE PROCEDURE spLogMeIn
@User_ID Varchar(50),
@Password Varchar(50),
@Success int output
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT ON;
Select @success = case when exists (select 1 from customer 
            where [user_ID] =@User_ID and Password=@password
            ) then -1 else 0 end
END


--pop some spoof data into the table....
insert into Customer 
    (Firstname, Surname, User_ID, Password, 
        Creditcardno, SortCode, AccountNo)
Select 'Joe', 'McTavish','Foo','plasticShoe',
        '7666923165777980','23-45-67','040592739'
insert into Customer 
    (Firstname, Surname, User_ID, Password, 
        Creditcardno, SortCode, AccountNo)
Select 'Lars', 'Porsenna','Abe','ninegods',
        '5960711184930897','76-54-23','014354678'
insert into Customer 
    (Firstname, Surname, User_ID, Password, 
        Creditcardno, SortCode, AccountNo)
Select 'Abou', 'Ben-Adam','Tribe','increase',
        '9807493817364950','08-48-37','003948673'
insert into Customer 
    (Firstname, Surname, User_ID, Password, 
        Creditcardno, SortCode, AccountNo)
Select 'Phil', 'Factor','jig','flutersball',
        '7666923165777980','22-45-44','020594835'

/* Now it is possible that we will want to allow the application access
to a view of the customer information without the sensitive 
information.
Here is a simple view to illustrate such a view....*/
CREATE VIEW [dbo].[vCustomer]
AS
SELECT     Customer_ID, Firstname, Surname, User_ID, InsertionDate
FROM         dbo.Customer

GO
--now, all we need to do is to grant access to it by the application
GRANT INSERT ON [dbo].[vCustomer] TO [Workbench]
GO
GRANT REFERENCES ON [dbo].[vCustomer] TO [Workbench]
GO
GRANT SELECT ON [dbo].[vCustomer] TO [Workbench]
GO
GRANT UPDATE ON [dbo].[vCustomer] TO [Workbench]
GO

/* We'll also create a procedure that returns a table that would
provide a recordset to .NET
*/
CREATE procedure spCustomer
AS
SELECT     Customer_ID, Firstname, Surname, User_ID, InsertionDate
FROM         dbo.Customer

GO

--and grant access to it, by the application
GRANT EXECUTE ON [dbo].[spcustomer] TO [Workbench]

/* and now we do a stored procedure which uses 'Dynamic' SQL. This
will serve to show how Dynamic SQL can cause problems */
CREATE procedure spCustomerWithDynamicSQL
AS
Execute ('SELECT  Customer_ID, Firstname, Surname, User_ID, 
    InsertionDate FROM dbo.Customer')

GO
--and grant access to it, by the application
GRANT EXECUTE ON [dbo].[spCustomerWithDynamicSQL] TO [Workbench]

/* and we ought to experiment with a function, to see what happens
in this case...*/

CREATE  FUNCTION [dbo].[uftCustomer]
(
)
RETURNS
@Results TABLE
(
    [Customer_ID] [int] ,
    [Firstname] [varchar](50),
    [Surname] [varchar](50),
    [User_ID] [varchar](20),
    [InsertionDate] [datetime] 
)
AS
begin
insert into @Results
    (Customer_ID, Firstname,Surname,[User_ID],InsertionDate)
select Customer_ID, Firstname,Surname,[User_ID],InsertionDate
    from customer
return
end
GO
GRANT SELECT ON [dbo].[uftCustomer] TO [Workbench]

/* ..and a view that encapsulates a function just to test out
what happens when you change permissions */
CREATE VIEW [dbo].[vCustomerViaFunction]
AS
SELECT     Customer_ID, Firstname, Surname, User_ID, InsertionDate
FROM         dbo.uftCustomer()

GO
GRANT SELECT ON [dbo].[vCustomerViaFunction] TO [Workbench]

/*
   Reassigning those 'Deny' roles
   ------------------------------

 the following block of code will drop the assignment
of all roles to our User, but assign him to the 
denydatawriter and denydatareader role*/

--'blanket' method to deny rights to make changes to tables
EXEC sp_droprolemember N'db_accessadmin', N'Workbench'
EXEC sp_droprolemember N'db_datawriter', N'Workbench'
EXEC sp_droprolemember N'db_datareader', N'Workbench'
EXEC sp_droprolemember N'db_owner', N'Workbench'
EXEC sp_droprolemember N'db_ddladmin', N'Workbench'
EXEC sp_droprolemember N'db_backupoperator', N'Workbench'
EXEC sp_droprolemember N'db_securityadmin', N'Workbench'
EXEC sp_addrolemember N'db_denydatawriter', N'Workbench'
EXEC sp_addrolemember N'db_denydatareader', N'Workbench'
GO
/*
Now try accessing the various objects we have created, using 
the code I've provided later on in the workbench. To do so
keep this code open in one window, and open a new window
using the Workbench login and mypassword password. Then
paste in the code inm the section entitled 'Try out accessing 
the test database'
-------------------------------------------------------------
When you've done that, execute the following code and see
what differences this makes. The following block of code will 
rescind the role that denies rights to select or make changes 
to tables*/
EXEC sp_droprolemember N'db_denydatareader', N'Workbench'
--and to read from them
EXEC sp_droprolemember N'db_denydatawriter', N'Workbench'
GO
/*
Now try accessing the various objects we have created, using 
the code I've provided later on in the workbench.


    Taking out the 'permission' donkey work
    ---------------------------------------

 Now the problem with implementing this sort of level of 
security is that your database probably has loads
of tables and stored procedures and going through SSMS,
doing everything by hand is going to be a nightmare. So here
is a simple stored procedure that sets the permissions for
the user you wish. */ 

Create procedure spDoAllPermissions 
@name varchar(100)
/*
spDoAllPermissions  'workbench'
*/
as
Declare @Command varchar(8000)--Varchar(MAX) in SQL Server 2005
Select @command=Coalesce(@command,'') + '
'+ case Table_Type when 'BASE TABLE' then
'
REVOKE INSERT ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
REVOKE DELETE ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
REVOKE REFERENCES ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
REVOKE SELECT ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
REVOKE UPDATE ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
'    
else
'
GRANT INSERT ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
-- GRANT DELETE ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
GRANT REFERENCES ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
GRANT SELECT ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
GRANT UPDATE ON ['+TABLE_SCHEMA+'].['+TABLE_NAME+'] TO ['+@name+']
'    end    
 from information_schema.tables where TABLE_NAME not like 'sys%'
Select @command=@command+ '
GRANT '+case routine_type 
        when 'procedure' then 'EXECUTE' 
        else 'SELECT' end
    +' ON ['+ROUTINE_SCHEMA+'].['+ROUTINE_NAME+'] TO ['+@name+']'
from information_Schema.routines 
where ROUTINE_NAME <> 'spDoAllPermissions'
Execute (@Command)



/*The Test harness
  ----------------
Now the test database is constructed, we can try out the two
different security models

Firstly, open up a new window in SSMS or Query 
Manager, but using the workbench login ID and 'mypassword' password


You can try out the following- paste it all into the new window.
Don't execute it in this window!

To execute this following code, we must be logged in as WorkBench 
(password: mypassword)
don't execute it whilst logged in as DBO!
to change between the two secuity schemes, execute one of the two
blocks of code in the section 'Reassigning those 'Deny' roles'*/


use SecurityWorkbench
-- can we use a view?
Select * from vcustomer

-- what about executing a stored procedure that returns the (censored)
-- data from the table
execute spCustomer

-- Can you use a stored procedure that contains dynamic SQL. If not, 
-- then why not (The answer is in the SQL Server Security Cribsheet)
execute spCustomerWithDynamicSQL

-- Msg 229, Level 14, State 5, Line 1
--     SELECT permission denied on object 'Customer', 
--     database 'SecurityWorkbench', owner 'dbo'.

-- can we access a table directly?
select * from customer

-- or insert into a view?
insert into  vcustomer (firstname, surname,[user_ID])  
    select 'Akund','Swat','Who'

-- or indulge in wickedness?
master..xp_cmdshell 'Dir c:\'
drop table customer
Delete from customer
select * from information_schema.tables
execute sp_help
execute sp_who
kill 52

-- can we access a table function?
Select * from dbo.uftCustomer() where surname like 'factor'

-- or use a view containing a table function?
Select * from  vCustomerViaFunction

-- and lastly, can we, without having any table access, check a
-- User_ID and password
declare @success int
execute LogMeIn @user_id='jig',@password='flutersball',
    @success=@success out
Select @success







