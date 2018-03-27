#!/usr/bin/env python

from __future__ import print_function

import json
import sys
import os
import errno
from datetime import date
import pyodbc
import requests

from requests.auth import HTTPBasicAuth

from config import config

import util

WORKDAY_WORKERS_URL='https://services1.myworkday.com/ccx/service/customreport2/vhr_mozilla/sstorey/IT_Data_Warehouse_Worker_Sync_Full_File?format=json'

def fetch_data():
    try:
        auth = HTTPBasicAuth(config['w_username'], config['w_password'])
        data = requests.get(WORKDAY_WORKERS_URL, auth=auth)
        results = json.loads(data.text)
        parse_data(results)
    except BaseException:
        print(sys.exc_info()[0], file=sys.stdout)
        raise

def parse_data(results):
    print("Writing to %s" % config['tmp_file'])
    output_file = open(config['tmp_file'], "w")
    employees = results['Report_Entry']
    for emp in employees:
        try:
            line = []
            line.append(emp['Employee_ID'])
            line.append(emp['First_Name'])
            line.append(emp['Last_Name'])
            line.append(emp['Email_Address']) if 'Email_Address' in emp else line.append('')
            line.append(emp['Supervisory_Organization']) if 'Supervisory_Organization' in emp else line.append('')
            line.append(emp['Cost_Center']) if 'Cost_Center' in emp else line.append('')
            line.append(emp['Functional_Group']) if 'Functional_Group' in emp else line.append('')
            line.append(emp['Manager_ID']) if 'Manager_ID' in emp else line.append('')

            if 'Manager_Name' in emp:
                line.append(emp['Manager_Name'].split(',')[0])
                line.append(emp['Manager_Name'].split(',')[1])
            else:
                line.append('')
                line.append('')

            line.append(emp['Is_Manager']) if 'Is_Manager' in emp else line.append('')
            line.append(emp['Hire_Date']) if 'Hire_Date' in emp else line.append('')
            line.append(emp['Location']) if 'Location' in emp else line.append('')
            line.append(config['today'])

            print(','.join(map(util.convert_value, line)), file=output_file)
        except BaseException:
            print(sys.exc_info()[0], file=sys.stdout)
            raise

def push_to_vertica():
    tmp_file = config['tmp_file']

    try:
        cnxn = pyodbc.connect("DSN=vertica", autocommit=False)
        cursor = cnxn.cursor()
    except BaseException:
        print(sys.exc_info()[0], file=sys.stdout)
        raise

    try:
        sql = "DELETE FROM {table_name} WHERE {today_field} = ?"
        sql = sql.format(table_name=config['v_table'],
                         today_field=config['v_today_field'],
                        )

        delete_count = cursor.execute(sql, config['today']).rowcount

        sql = "COPY {table_name} ({table_fields}) FROM LOCAL '{local_path}' DELIMITER '{delimiter}' EXCEPTIONS '{exceptions}' REJECTED DATA '{rejected}' NO COMMIT"
        sql = sql.format(table_name=config['v_table'],
                         table_fields=",".join(config['v_fields'] + [config['v_today_field']]),
                         local_path=tmp_file,
                         delimiter=',',
                         exceptions=tmp_file + '_exceptions.txt',
                         rejected=tmp_file + '_rejected.txt',
                        )

        copy_count = cursor.execute(sql).rowcount

        sql = "insert into last_updated (name, updated_at, updated_by) values (?, now(), ?)"

        last_updated_count = cursor.execute(sql, config['v_table'] , __file__).rowcount

        print("Deleted: %d, Loaded: %d, Last_updated: %d" % (delete_count, copy_count, last_updated_count))

        cursor.commit()
    except BaseException:
        print(sys.exc_info()[0], file=sys.stdout)
        raise

def init_config():
    try:
        if len(sys.argv) == 2:
            config['today'] = sys.argv[1]
        else:
            config['today'] = str(date.today())

	if not 'base_dir' in config:
	    config['base_dir'] = '/tmp'

        config['tmp_dir'] = config['base_dir'] + "/" + config['today']
        util.mkdir_p(config['tmp_dir'])
        config['tmp_file'] = config['tmp_dir'] + "/" + config['v_table']
    except BaseException:
        print(sys.exc_info()[0], file=sys.stdout)
        raise

if __name__ == "__main__":
    init_config()
    fetch_data()
    push_to_vertica()
    util.cleanup(config['tmp_dir'])
