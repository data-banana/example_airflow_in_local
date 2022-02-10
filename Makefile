VENV=venv
VENV_ACTIVATE=source ${VENV}/bin/activate
AIRFLOW_V1_VERSION=1.10.15
AIRFLOW_V2_VERSION=2.2.3
PYTHON_VERSION=3.8
PYTHON_PATH=python
AIRFLOW_HOME=~/airflow
AIRFLOW_CFG=airflow.cfg
DAG_FOLDER_PATH=$$(pwd)/airflow-local/dag
CONF_PATTERN_DAGS_FOLDER=dags_folder = .*
CONF_REPLACEMENT_DAGS_FOLDER=dags_folder = $(DAG_FOLDER_PATH)



SHELL := /bin/bash


install-v1:
	rm -r ${VENV} || true
	rm -r $(AIRFLOW_HOME) || true
	$(PYTHON_PATH) -m pip install virtualenv
	$(PYTHON_PATH) -m virtualenv -p python3 ${VENV}
	$(VENV_ACTIVATE); python -m pip install -U -q pip
	$(VENV_ACTIVATE); pip install -U -q  "apache-airflow==${AIRFLOW_V1_VERSION}" \
	--constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_V1_VERSION}/constraints-${PYTHON_VERSION}.txt"
	$(VENV_ACTIVATE); pip install -U -q -r requirements-dev.txt
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	$(VENV_ACTIVATE); airflow db init || airflow initdb
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|${CONF_PATTERN_DAGS_FOLDER}|${CONF_REPLACEMENT_DAGS_FOLDER}|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|load_examples = .*|load_examples = False|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|dag_dir_list_interval = .*|dag_dir_list_interval = 10|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|catchup_by_default = .*|catchup_by_default = False|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|store_serialized_dags = .*|store_serialized_dags = True|g" {} \;
	$(VENV_ACTIVATE); airflow resetdb -y


install-v2:
	rm -r ${VENV} || true
	rm -r $(AIRFLOW_HOME) || true
	$(PYTHON_PATH) -m pip install virtualenv
	$(PYTHON_PATH) -m virtualenv -p python3 ${VENV}
	$(VENV_ACTIVATE); python -m pip install -U -q pip
	$(VENV_ACTIVATE); pip install -U -q "apache-airflow==${AIRFLOW_V2_VERSION}" \
	--constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_V2_VERSION}/constraints-${PYTHON_VERSION}.txt"
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	$(VENV_ACTIVATE); airflow db init || airflow initdb
	$(VENV_ACTIVATE); airflow users create --username admin --password admin --firstname admin --lastname admin --role Admin --email admin@admin.org
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|${CONF_PATTERN_DAGS_FOLDER}|${CONF_REPLACEMENT_DAGS_FOLDER}|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|load_examples = .*|load_examples = False|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|dag_dir_list_interval = .*|dag_dir_list_interval = 10|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|catchup_by_default = .*|catchup_by_default = False|g" {} \;
	find $(AIRFLOW_HOME)/$(AIRFLOW_CFG) -type f -exec sed -i "" -e "s|store_serialized_dags = .*|store_serialized_dags = True|g" {} \;
	$(VENV_ACTIVATE); airflow db reset -y



start-airflow:
	$(VENV_ACTIVATE); airflow scheduler &
	$(VENV_ACTIVATE); airflow webserver --port 8080


# Be carefull with pkill python
stop-airflow:
	cat $(AIRFLOW_HOME)/airflow-webserver.pid | xargs kill -9 || true
	cat $(AIRFLOW_HOME)/airflow-scheduler.pid | xargs kill -9 || true
	pkill airflow > /dev/null 2> /dev/null || true
	pkill python > /dev/null 2> /dev/null || true 
