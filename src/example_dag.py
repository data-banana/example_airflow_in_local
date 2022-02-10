from airflow.operators.python_operator import PythonOperator
from airflow import DAG
from airflow.utils.dates import days_ago



default_args = {
    "start_date": days_ago(1),
    "owner": "Data Banana",
    'retries': 0,
}
dag = DAG(
    'example_dag',
    default_args=default_args,
    schedule_interval='1 1 * * *',
    description='Stupid DAG'
)


def do_something(**kwargs):
    print("do something")


t1 = PythonOperator(
    task_id='task1',
    python_callable=do_something,
    dag=dag,
)
t2 = PythonOperator(
    task_id='task2',
    python_callable=do_something,
    dag=dag,
)
t3 = PythonOperator(
    task_id='task3',
    python_callable=do_something,
    dag=dag,
)


t1 >> t2 >> t3