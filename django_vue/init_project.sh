#!/usr/bin/env bash

GITHUB_FILE_URI=https://raw.githubusercontent.com/RivenZoo/scaffold/master/django_vue
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename ${PROJECT_DIR})
PROJECT_APP=${PROJECT_NAME}_app
PYTHON_REQUIREMENTS=requirements.txt
ASSIST_FILES=(Dockerfile Makefile run.sh)
FILE_CHECK_LIST=(${PYTHON_REQUIREMENTS} ${ASSIST_FILES[@]})

function log {
	echo $(date +"%Y%m%d %H:%M:%S") " $@"
}

function install_pipenv {
	pipenv=$(which pipenv)
	if [[ -z "${pipenv}" ]]; then
		pip install --user pipenv
	fi
	log "pipenv: $(which pipenv)"
}

function setup_django {
	cd ${PROJECT_DIR}
	log "setup_django in $(pwd)"
	PIPENV_VENV_IN_PROJECT=1 pipenv --three
	if [[ ! -d .venv ]]; then
		log "generate virtualenv fail"
		exit -1
	fi
	if [[ ! -f ${PYTHON_REQUIREMENTS} ]]; then
		log "no requirements file"
		exit -1
	fi
	PIPENV_VENV_IN_PROJECT=1 pipenv run pip install -r ${PYTHON_REQUIREMENTS}
	PIPENV_VENV_IN_PROJECT=1 pipenv run .venv/bin/django-admin startproject ${PROJECT_NAME}
	cd ${PROJECT_NAME} && PIPENV_VENV_IN_PROJECT=1 pipenv run python manage.py startapp ${PROJECT_APP}
}

function setup_crontab {
	mkdir ${PROJECT_DIR}/${PROJECT_NAME}/crontab
	echo "# 0 * * * * echo 1" > ${PROJECT_DIR}/${PROJECT_NAME}/crontab/crontab.conf
}

function setup_django_settings {
	cd ${PROJECT_DIR}/${PROJECT_NAME}/${PROJECT_APP}
	settings=settings.py
	echo "# install app" >> ${settings}
	cat << EOF >> ${settings}
INSTALLED_APPS.extend(["${PROJECT_APP}", "corsheaders"])
EOF
	echo "# add middleware" >> ${settings}
	cat << EOF >> ${settings}
MIDDLEWARE.extend(['corsheaders.middleware.CorsMiddleware'])
EOF
	echo "# add cors settings"
	cat << EOF >> ${settings}
CORS_ORIGIN_ALLOW_ALL = True # only for debug
CORS_ORIGIN_WHITELIST = ()
EOF
	echo "# set vue static files"
	cat << EOF >> ${settings}
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "frontend/dist/static"),
]
EOF
	tmpname=${settings}.$(mktemp XXXXXX)
	sed "s|'DIRS': \[\],|'DIRS': ['frontend/dist'],|" ${settings} > ${tmpname}
	PIPENV_VENV_IN_PROJECT=1 pipenv run python -m py_compile ${tmpname}
	if [[ $? -eq 0 ]]; then
		log "setup django settings finish"
		mv ${tmpname} ${settings}
	fi
}

function setup_vue {
	npm install vue -g
	npm install vue-cli -g
	cd ${PROJECT_DIR}/${PROJECT_NAME}
	vue-init webpack frontend
	cd frontend && npm run build
}

function set_assist_files {
	for f in ${ASSIST_FILES[@]}; do
		tmpname=${f}.$(mktemp XXXXXX)
		sed -e "s|PROJECT_NAME|${PROJECT_NAME}|g" \
		  -e "s|PROJECT_APP|${PROJECT_APP}|g" ${f} > ${tmpname}
		mv ${tmpname} ${f}
	done
}

function check_and_download_files {
	for f in ${FILE_CHECK_LIST[@]}; do
		if [[ ! -f ${f} ]]; then
			url=${GITHUB_FILE_URI}/${f}
			log "file ${f} not exist, download from ${url}"
			curl "${url}" -o ${f}
		fi
	done
}

check_and_download_files
install_pipenv
setup_django
setup_crontab
setup_vue
setup_django_settings
set_assist_files
