"""
    ___  ___  ______  |  
   / _ \/ _ \|  ____| |  agile    
  / / \ \/ \ \ |__    |  automation
 / /  /\ \  \ \ __|   |  factory   
/_/  /_/\_\  \_\      | 

Vaultspeed version: 4.2.3.9, generation date: 2021/02/25 11:13:53
DV_NAME: IIE_Datavault - Release: Release 15(15) - Comment: Release 15 - Release date: 2021/02/23 12:50:43, 
SRC_NAME: ODS_D365 - Release: ODS_D365(40) - Comment: Release 40 - Release date: 2021/02/23 12:48:48
 """


from datetime import datetime, timedelta
from pathlib import Path
import json

from airflow import DAG
from airflow.models import Variable
from airflow.operators.jdbc_operator import JdbcOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.vs_fmc_plugin import JdbcToXcom


default_args = {
	"owner":"Vaultspeed",
	"retries": 3,
	"retry_delay": timedelta(seconds=10),
	"start_date":datetime.strptime("25-02-2021 14:00:00", "%d-%m-%Y %H:%M:%S")
}

path_to_mtd = Path(Variable.get("path_to_metadata"))

IIE_DataVault_INCR_Daily = DAG(
	dag_id="IIE_DataVault_INCR_Daily", 
	default_args=default_args,
	description="IIE_DataVault_INCR_Daily", 
	schedule_interval="@daily", 
	concurrency=4, 
	catchup=False, 
	max_active_runs=1
)

# Create initial fmc tasks
#Get the end date of the previous successful load
fmc_prev_load = JdbcToXcom(
	task_id="fmc_prev_load", 
	jdbc_conn_id="TARGETDB", 
	sql="""SELECT CONVERT(VARCHAR, FMC_END_LW_TIMESTAMP, 121) 
		FROM IIEDataVault_FMC.FMC_LOAD_HIST 
		WHERE [SOURCE_SYSTEM] = 'ODS_D365' AND success_flag = 1 
		ORDER BY LOAD_CYCLE_ID DESC""", 
	dag=IIE_DataVault_INCR_Daily
)

# insert load metadata
fmc_mtd = JdbcOperator(
	task_id="fmc_mtd", 
	jdbc_conn_id="TARGETDB", 
	sql=["""INSERT INTO IIEDataVault_FMC.FMC_LOAD_HIST 
		SELECT 
			'{{ dag_run.dag_id }}',
			'ODS_D365',
			{{ dag_run.id }},
			CONVERT(DATETIME2, '{{ next_execution_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121),
			CONVERT(DATETIME2, '{{ task_instance.xcom_pull(task_ids="fmc_prev_load")[0] or execution_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121),
			CONVERT(DATETIME2, '{{ next_execution_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121),
			CONVERT(DATETIME2, '{{ dag_run.start_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121),
			null,
			null
		WHERE NOT EXISTS(SELECT 1 FROM IIEDataVault_FMC.FMC_LOAD_HIST WHERE LOAD_CYCLE_ID = {{ dag_run.id }})""", 
		"""TRUNCATE TABLE dc.LOAD_CYCLE_INFO""", 
		"""INSERT INTO dc.LOAD_CYCLE_INFO(LOAD_CYCLE_ID,LOADDT) 
			SELECT {{ dag_run.id }},CONVERT(DATETIME2, '{{ next_execution_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121)""", 
		"""TRUNCATE TABLE dc.FMC_LOADING_WINDOW_DT""", 
		"""INSERT INTO dc.FMC_LOADING_WINDOW_DT(FMC_BEGIN_LW_TIMESTAMP,FMC_END_LW_TIMESTAMP) 
			SELECT CONVERT(DATETIME2, '{{ (task_instance.xcom_pull(task_ids="fmc_prev_load")[0] or execution_date.strftime("%Y-%m-%d %H:%M:%S.%f")) }}', 121), CONVERT(DATETIME2, '{{ next_execution_date.strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121)"""], 
	dag=IIE_DataVault_INCR_Daily
)
fmc_mtd << fmc_prev_load

tasks = {"fmc_mtd":fmc_mtd}

# Create mapping tasks
if (path_to_mtd / "77_mappings_IIE_DataVault_INCR_Daily_20210225_111353.json").exists():
	with open(path_to_mtd / "77_mappings_IIE_DataVault_INCR_Daily_20210225_111353.json") as file: 
		mappings = json.load(file)

else:
	with open(path_to_mtd / "mappings_IIE_DataVault_INCR_Daily.json") as file: 
		mappings = json.load(file)

for map, deps in mappings.items():
	task = JdbcOperator(
		task_id=map, 
		jdbc_conn_id="TARGETDB", 
		sql=f"EXEC IIEDataVault_PROC.{map};", 
		dag=IIE_DataVault_INCR_Daily
	)
	

	for dep in deps:
		task << tasks[dep]
	
	tasks[map] = task
	

# task to indicate the end of a load
end_task = DummyOperator(
	task_id="end_of_load", 
	dag=IIE_DataVault_INCR_Daily
)

# Set end of load dependency
if (path_to_mtd / "77_FL_mtd_IIE_DataVault_INCR_Daily_20210225_111353.json").exists():
	with open(path_to_mtd / "77_FL_mtd_IIE_DataVault_INCR_Daily_20210225_111353.json") as file: 
		analyse_tasks = json.load(file)
else:
	with open(path_to_mtd / "FL_mtd_IIE_DataVault_INCR_Daily.json") as file: 
		analyse_tasks = json.load(file)

for table, deps in analyse_tasks.items():
	for dep in deps:
		end_task << tasks[dep]

# Save load status tasks
fmc_load_fail = JdbcOperator(
	task_id="fmc_load_fail", 
	jdbc_conn_id="TARGETDB", 
	sql="""UPDATE IIEDataVault_FMC.FMC_LOAD_HIST 
		SET success_flag = 0, 
		    load_end_date = CONVERT(DATETIME2, '{{ macros.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121)
		WHERE LOAD_CYCLE_ID = {{ dag_run.id }} """,
	trigger_rule="one_failed",
	dag=IIE_DataVault_INCR_Daily
)
fmc_load_fail << end_task

fmc_load_success = JdbcOperator(
	task_id="fmc_load_success", 
	jdbc_conn_id="TARGETDB", 
	sql="""UPDATE IIEDataVault_FMC.FMC_LOAD_HIST 
		SET success_flag = 1, 
		    load_end_date = CONVERT(DATETIME2, '{{ macros.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f") }}', 121)
		WHERE LOAD_CYCLE_ID = {{ dag_run.id }} """,
	dag=IIE_DataVault_INCR_Daily
)
fmc_load_success << end_task

