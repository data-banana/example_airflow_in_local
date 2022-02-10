# Example - run airflow in local

This is an __example__ of how you can run airflow in local.

There is an util function to test only some tasks of a DAG, and skipped the others.
This can be useful when you have tasks with database operations,  and you want to limit the data consumption.

## Installation and configuration

The goal here is to install airflow in a virtual environment and change of airflow the configuration for the dag folder to use the DAGs fro m this project.

To help you to achieve it, there is a makefile with all of the steps. But maybe it's not appropriate to your OS/config.
You may have to adapt this file.


After that, run the command to install Airflow `v2`:
```bash
make install-v2
```

Or run the command to install Airflow `v1`:
```bash
make install-v1
```

If you don't have any error, you can run Airflow in a local server like this:

```bash
make start-airflow
```

It will start the airflow server. When you have finishn you can stop the current process with `Ctrl+C` or with the command `make stop-airflow`.

## Example

We have a simple DAG like this:
```python
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
```

Now we imagine that some of the tasks are related to database actions. So maybe, we don't want to run all of the tasks when we run this DAG locally, 
to do it we have this util test function:

```python
dag = test_dag('example_dag', ['task3'])
```

<img src='data:image/png;base64,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'>



task1:
```log
INFO - do nothing
```

task2:
```log
INFO - do nothing
```

task3:
```log
INFO - do something
```

Here, it will only executed the code of the **task3**. 