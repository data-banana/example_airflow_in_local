import sys
import os
PATH = os.path.dirname(os.path.abspath(__file__))
PARENT = os.path.abspath(os.path.join(PATH, os.pardir))
sys.path.append(PARENT)
from util_test_airflow import test_dag
from airflow import DAG





# Example - We test the dag example_dag.py
# All tasks are skipped except task3, that is executed
dag = test_dag('example_dag', ['task3'])
# Or if you want to skip all tasks
# dag = test_dag('example_dag')