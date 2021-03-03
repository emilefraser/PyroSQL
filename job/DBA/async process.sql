28

It looks like there are multiple ways to accomplish this, but I found the simplest way was Martin's suggestion of setting up the procedure in a SQL job, and starting it using the asynchronous sp_start_job command from my stored procedure.

EXEC msdb.dbo.sp_start_job @job_name='Run2ndStoredProcedure'
This only works for me because I don't need to specify any parameters for my stored procedure.

Other suggestions that may work depending on your situation are

Using the SQL Service Broker like Martin and Sebastian suggest. This is probably the best suggestion if you don't mind the complexity of setting it up and learning how it works.
Running the process asynchronously in the code that is responsible for executing the stored procedure, like Mr.Brownstone suggested.

Not a bad idea, however in my case the stored procedure gets called from multiple places, so finding all those places and ensuring they call the 2nd procedure too didn't seem that practical. Also, the 2nd stored procedure is fairly critical, and forgetting to run it could cause some major problems for our company.

Make the 1st procedure set a flag, and setup a recurring job to check for that flag and run if its set, like Jimbo suggested. I'm not a big fan of jobs that run constantly and check for changes every few minutes, but it certainly is an option worth considering depending on your situation.
shareimprove this answer
edited Jun 16 '17 at 16:26

Fruitbat
10322 bronze badges
answered Feb 18 '13 at 15:06

Rachel
7,7791818 gold badges4444 silver badges7373 bronze badges
4
Have a look at Asynchronous Procedure Execution for an ready-to-use example using Service Broker. The advantages over sp_job is that it works on Express Edition and is entirely DB contained (no dependency on MSDB job tables). The later is very important in DBM failover and on HA/DR recovery. – Remus Rusanu Feb 18 '13 at 21:29
Shoot, I see Martin linked the same article. I'll leave the comment for the failover/DR arguments. – Remus Rusanu Feb 18 '13 at 21:31
@RemusRusanu: well, that's one of the best sources of information regarding Service Broker, but I suppose you knew already ;-). – Marian Feb 19 '13 at 18:07
I liked the link from @Rusanu, but I wanted something with no response (which I think matches this problem). I wrote up my simplified version at abamacus.blogspot.com/2016/05/… – Abacus May 11 '16 at 21:09
Also if you try to start an SQL Agent job, it will fail with The EXECUTE permission was denied on the object 'sp_start_job', database 'msdb', schema 'dbo'. Also neither Service Broker, or Sql Agent, exist on Azure. I don't know why Microsoft, after a decade and a half of people asking, refuse to add EXECUTE ASYNC RematerializeExpensiveCacheTable. – Ian Boyd Aug 2 '17 at 14:47 
add a comment

8

You could use service broker together with activation on the queue. With that you could post the parameters for the procedure call on the queue. That takes about as much time as an insert. After the transaction is committed and potentially a few more seconds, activation would automatically call the receiver procedure asynchronously. It than just wuold have to take the parameters of the queue and do the desired work.

shareimprove this answer
answered Feb 18 '13 at 14:57

Sebastian Meine
8,41211 gold badge2020 silver badges2828 bronze badges
add a comment

8

This old question deserves a more comprehensive answer. Some of these are mentioned in other answers/comments here, others may or may not work for OP's specific situation, but might work for others looking for calling stored procs asynchronously from SQL.

Just to be totally explicit: TSQL does not (by itself) have the ability to launch other TSQL operations asynchronously.

That doesn't mean you don't still have a lot of options:

SQL Agent jobs: Create multiple SQL jobs, and either schedule them to run at the time desired, or start them asynchronously from a "master control" stored proc using sp_start_job. If you need to monitor their progress programatically, just make sure the jobs each update a custom JOB_PROGRESS table (or you can check to see if they have finished yet using the undocumented function xp_sqlagent_enum_jobs as described in this excellent article by Gregory A. Larsen). You have to create as many separate jobs as you want parallel processes running, even if they are running the same stored proc with different parameters.
SSIS Package: For more complicated asynchronous scenarios, create an SSIS package with a simple branching task flow. SSIS will launch those tasks in individual spids, which SQL will execute in parallel. Call the SSIS package from a SQL agent job.
Custom application: Write a simple custom app in the language of your choice (C#, Powershell, etc), using the asynchronous methods provided by that language. Call a SQL stored proc on each application thread.
OLE Automation: In SQL, use sp_oacreate and sp_oamethod to launch a new process calling each other stored proc as described in this article, also by Gregory A. Larsen.
Service Broker: Look into using Service Broker, a good example of asynchronous execution in this article.
CLR Parallel Execution: Use the CLR commands Parallel_AddSql and Parallel_Execute as described in this article by Alan Kaplan (SQL2005+ only).
Scheduled Windows Tasks: Listed for completeness, but I'm not a fan of this option.
If it were me, I'd probably use multiple SQL Agent Jobs in simpler scenarios, and an SSIS package in more complex scenarios.

In your case, calling SQL Agent jobs sounds like a simple and manageable choice.

One final comment: SQL already attempts to parallelize individual operations whenever it can*. This means that running 2 tasks at the same time instead of after each other is no guarantee that it will finish sooner. Test carefully to see whether it actually improves anything or not.

We had a developer that created a DTS package to run 8 tasks at the same time. Unfortunately, it was only a 4-CPU server :)

*Assuming default settings. This can be modified by altering the server's Maximum Degree of Parallelism or Affinity Mask, or by using the MAXDOP query hint.