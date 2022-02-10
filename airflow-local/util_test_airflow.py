import os
import sys
from airflow.models.baseoperator import BaseOperator


def test_dag(dag_name, tasks_id_to_run=[]):

    def do_nothing(context):
        print('do nothing')
        pass

    def recursive_disabled_tasks(tasks, tasks_id_to_run):
        for i in range(len(tasks)):
            if tasks[i].task_id not in tasks_id_to_run:
                tasks[i].execute = do_nothing
            if len(tasks[i].downstream_list) > 0:
                recursive_disabled_tasks(tasks[i].downstream_list, tasks_id_to_run)

    SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
    # Add path where are located DAGs, depend on your project ...
    sys.path.append(os.path.normpath(os.path.join(SCRIPT_DIR, os.pardir, 'src')))
    # import DAG
    module = __import__(dag_name)
    # transform module object to dict, get vairables
    variables = {a: module.__getattribute__(a) for a in dir(module)}


    # Get tasks from simple global variable
    tasks = list(filter(lambda x: isinstance(x, BaseOperator), variables.values()))
    # Get tasks from list of tasks in global variable
    list_var = list(filter(lambda x: isinstance(x, list), variables.values()))
    for l in list_var:
        for var in l:
            if isinstance(var, BaseOperator):
                tasks.append(var)
    # TODO: complete, for exemple if you declare DAGs in other objects type, like dict
    # ...
    
    # Disabled task, add dummy function
    recursive_disabled_tasks(tasks, tasks_id_to_run)

    dag = variables.get('dag')
    # Add suffix to the dag name
    dag.dag_id += '_test'
    return dag