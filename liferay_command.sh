#!/bin/bash
set -e

#========================
## Commands
#========================
COMMAND="$1"
PARAMS="$2"
CURRENT_DIR=$(pwd)
#JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home

#========================
## Variables
#========================
LIFERAY_HOME=$CURRENT_DIR
LIFERAY_BUNDLE=$LIFERAY_HOME/bundles
LIFERAY_DOCUMENT_LIBRARY_DIR=${LIFERAY_BUNDLE}/data/document_library
DATABASE=lportal
DATABASE_ROOT_PASSWORD=root

#========================
## Files
#========================
DL_BACKUP_FILE=$LIFERAY_HOME/backups/document_library.zip
DB_BACKUP_FILE=$LIFERAY_HOME/backups/database.zip
DB_DUMP_FILE=$LIFERAY_HOME/dump/mysql.sql

#========================
## Colors
#========================
blue=$'\e[1;34m'
cyan=$'\e[1;36m'
white=$'\e[0m'
red=$'\e[31m'
yellow=$'\e[33m'

#========================
## Containers
#========================
down_docker_app() {
  log_info "=> TASK: remove_docker_app"

  log_debug docker-compose -f $LIFERAY_HOME/docker-compose-mac.yaml down
}

up_docker_app() {
  log_info "=> TASK: create_docker_app"

  log_debug docker-compose -f $LIFERAY_HOME/docker-compose-mac.yaml up -d
}

build_project() {
  log_info "=> TASK: build_project"
  if [[ ! -z $(find $LIFERAY_HOME/modules -type d -empty) ]]; then
    cd $LIFERAY_HOME/modules
    log_debug blade gw deploy
    cd -
  fi

}

build_theme() {
  log_info "=> TASK: build_theme"

  if [[ ! -z $(find $LIFERAY_HOME/themes -type d -empty) ]]; then
    cd $LIFERAY_HOME/themes
    log_debug blade gw deploy
    cd -
  fi
}

#========================
## Save and Load State
#========================
save_state() {
  log_info "Warning: You will generate a backup!";
  log_debug read -p "Press any key to continue..." -n1 -s

  if [ ! -d $LIFERAY_HOME/backups ]; then
    mkdir $LIFERAY_HOME/backups
  else
    rm -rf $LIFERAY_HOME/backups/*
  fi

  log_info "Info: Backup document and library to $DL_BACKUP_FILE";
  if [ -d $LIFERAY_BUNDLE/data/document_library ]; then
    cd $LIFERAY_BUNDLE/data/document_library && zip -r $DL_BACKUP_FILE * && cd -
  fi

  log_info "Info: Backup database to $DB_BACKUP_FILE";
  docker exec mysql sh -c "exec mysqldump --all-databases -uroot --password=root"> $LIFERAY_HOME/backups/mysql.sql
  cd $LIFERAY_HOME/backups && zip $DB_BACKUP_FILE mysql.sql && cd -
  rm $LIFERAY_HOME/backups/mysql.sql

  remove_dump_file
}

load_backup(){
  log_info "=> TASK: load_backup"

  if [ ! -d $LIFERAY_BUNDLE/data/document_library ]; then
    log_debug mkdir -p $LIFERAY_BUNDLE/data/document_library
  fi

  log_debug rm -rf $LIFERAY_BUNDLE/data/document_library/*

  if test -f "$DL_BACKUP_FILE"; then
    log_info "Unziping Document Library"
    log_debug unzip -o $DL_BACKUP_FILE -d $LIFERAY_BUNDLE/data/document_library
  else
    log_error "$DL_BACKUP_FILE not exist"
    exit 2
  fi

  if [ ! -d $LIFERAY_HOME/dump ]; then
    log_debug mkdir -p $LIFERAY_HIME/dump
  fi

  log_debug rm -rf $LIFERAY_HOME/dump/*

  if test -f "$DB_BACKUP_FILE"; then
    log_info "Copy Database File to dump folder"
    log_debug unzip -o $DB_BACKUP_FILE -d $LIFERAY_HOME/dump
  else
    log_error "$DB_BACKUP_FILE not exist"
    exit 2
  fi
}

remove_backup(){
  if [ -d "backups" ]; then
    log_info "Remove backup files"
    log_debug rm -rf $LIFERAY_HOME/backups
  fi
}

remove_dump_file(){
  if test -f "$DB_DUMP_FILE"; then
    log_info "Remove dump file $DB_DUMP_FILE"
    log_debug rm -rf $DB_DUMP_FILE
  fi
}

remove_bundle() {
  log_info "=> TASK: remove_bundle"
  read -p "This action will delete all the files inside (bundles) folder. Do you really want to proceed? [y/n]: " key
  if [[ $key = "y" ]]; then
    down_docker_app
    remove_backup
    remove_dump_file
    log_debug rm -rf bundles
    log_debug rm -rf build
    log_debug rm -rf node_modules
    log_debug rm -rf node_modules_cache
  else
    exit 1
  fi
}

remove_data() {
  log_info "=> TASK: remove_data"
  if [ ! -d $LIFERAY_BUNDLE/data/document_library ]; then
    log_debug rm -rf $LIFERAY_BUNDLE/data/document_library
  fi
}

#========================
## Debug
#========================
show_logs() {
  log_info "=> TASK: show_logs"
  docker logs -f liferay
}

log_date() {
  echo $(date '+%Y-%m-%d %H:%M:%S') "$@"
}

log_debug() {
  log_date "DEBUG.: " "$blue" "$@" "$white"
  "$@"
}

log_info() {
  echo "-------------------"
  log_date "INFO..: " "$cyan" "$@" "$white"
  echo "-------------------"
}

log_error() {
  echo "-------------------"
  log_date "ERROR..: " "$red" "$@" "$white"
  echo "-------------------"
}

log_warn() {
  echo "-------------------"
  log_date "WARN..: " "$yellow" "$@" "$white"
  echo "-------------------"
}

#========================
## Commands
#========================
init_command() {
  remove_dump_file
  up_docker_app
  build_project
  build_theme
}

start_command() {
  down_docker_app
  remove_data
  up_docker_app
}

stop_command() {
  read -p "You didn't back up, do you really want to proceed? [y/n]: " key
  if [[ $key = "y" ]]; then
    down_docker_app
    remove_dump_file
  fi
}

clean_command() {
  remove_bundle
}

save_state_command() {
  save_state
}

load_state_command() {
  down_docker_app
  load_backup
  up_docker_app
}

build_project_command(){
  build_project
  build_theme
  remove_dump_file
}

#========================
## Interface
#========================
case "${COMMAND}" in
  init ) init_command
        exit 0
        ;;
  start ) start_command
        exit 0
        ;;
  stop ) stop_command
        exit 0
        ;;
  backup ) save_state_command
        exit 0
        ;;
  restore ) load_state_command
        exit 0
        ;;
  deploy ) build_project_command
        exit 0
        ;;
  clean ) clean_command
        exit 0
        ;;
  logs ) show_logs
        exit 0
        ;; 
  *)
      echo $"Usage:" "$0" "{init | start | stop | backup | restore | deploy | clean | logs}"
      exit 1
esac
exit 0
