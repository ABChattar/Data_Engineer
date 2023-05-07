import pandas as pd
import mysql.connector
from sqlalchemy import create_engine
import configparser


def create_connection():
    config = configparser.ConfigParser()
    # Reading the config file
    config.read('config.ini')
    host = config['mysql']['host']
    username = config['mysql']['user']
    password = config['mysql']['password']
    database = config['mysql']['database']
    mysqldb=mysql.connector.connect(host=host,user=username,password=password,database=database)
    return mysqldb

def df_to_sql(df, conn, table_name,method):
    df.to_sql(table_name, con = conn, if_exists=method, index = False )

def exicute_sql_query(query):
    config = configparser.ConfigParser()
    # Reading the config file
    config.read('config.ini')
    host = config['mysql']['host']
    username = config['mysql']['user']
    password = config['mysql']['password']
    database = config['mysql']['database']
    mysqldb=mysql.connector.connect(host=host,user=username,password=password,database=database)#established connection   
    mycursor=mysqldb.cursor()#cursor() method create a cursor object 
    mycursor.execute(query)#Execute SQL Query to create a database  
    mysqldb.close()#Connection Close