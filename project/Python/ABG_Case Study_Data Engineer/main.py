import numpy as np
import pandas as pd
import re
import configparser 
from sqlalchemy import create_engine
from functions.transformation_functions import *
from functions.sql_functions import *
import warnings
warnings.filterwarnings("ignore")
import mysql.connector

class Extract_data():
    def source_data():
        """ This function is used to extract data from a dataset.
        The final output will be DataFrame """
        df = pd.read_csv("Data\dataset.csv",encoding='cp1252') 
        return df
    def sql_data(table_name):      

        # read the master_trip_data table into a pandas DataFrame
        #master_trip_data = pd.read_sql('master_trip_data', con=engine)
        mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",
        port=3306,
        database= 'ABG_Case_Study_Data_Engineer'
        )
        query=("select * from "+table_name)
        df = pd.read_sql(query, mydb)
        return df

class Transformations():
    def source_transformations(data):
        """ This function is used to transform data and clean up the dataset.
        The final output will be cleaned dataset """

        '''
        All the columns names should be Camel Case without any Special character and replace the space with underscore.
        example : "vehicle number" should be "Vehicle_Number"
        '''
        new_coulun_name=[]
        new_st = ''
        for i in list(data.columns):
            i = i.replace(" ", "_")
            print("print the i -->",i)
            new_st = captalize_data(i)
            new_coulun_name.append(new_st)
        print(new_coulun_name)
        data.columns=new_coulun_name

        '''In given dataset "trip no" column values should not have any other special characters except  '/' and ‘-’ .
        example : It should be like "HIL-DA-00013411/1" or "HIL-DA-00013411" or "HIL-00013411/"
            but the initial sholud be "HIL-DA-".
        '''
        data['Trip_No']= data['Trip_No'].apply(remove_special_char)

        '''Remove the special character from  column “vehicle number” and load the vehicle number value in sequence.'''
        data['Vehicle_Number'] = vehicle_number()
        '''column "plant" values should have only place name and it sholud be in Initial Captial'''
        Plant = []
        for i in data['Plant']:
            names = re.split('\W+', i)
            Plant.append(captalize_data(names[0]))
        data['Plant'] = Plant

        '''(a) column customer values should be in Camel casing with all the characters
            example : "LTD company mit" it sholud be "Ltd Company Mit"'''
        data['Customer'] = data['Customer'].apply(captalize_data)

        '''if there is in #N/A or blank fill as “Unknown Customer”'''
        data['Customer'] = data['Customer'].apply(fill_null_values, arg2=("Unknown Customer"),arg3 = (None))

        ''' In column "current location" there are latitude and longitudes so we need to separate these values to new  columns.
        while separating and create new columns as "Latitude" and "Longitude" and store the values.
        '''
        data[['Latitude', 'Longitude']] = data['Current_Location'].str.split(',', expand=True)
        data['Current_Location'].fillna('0,0',inplace=True)
        data['Latitude'].fillna('0',inplace=True)
        data['Longitude'].fillna('0',inplace=True)
        data['Current_Location'] = data['Current_Location'].apply(fill_null_values,arg2=("0,0"),arg3=('Inside Plant'))
        data['Latitude'] = data['Latitude'].apply(fill_null_values,arg2=("0"),arg3=('Inside Plant'))
        data['Longitude'] = data['Longitude'].apply(fill_null_values,arg2=("0"),arg3=('Inside Plant'))
        data['Latitude'] = data['Latitude'].apply(fill_null_values,arg2=("0"),arg3=('Inside Plant#N/A'))
        data['Latitude'] = data['Latitude'].astype(float)
        data['Longitude'] = data['Longitude'].astype(float)

        ''''In column "driver name" values should be all in Camel Casing and add a prefix "Mr. " 
        example : "RAJESH PRATAP SINGH" it should be ----> "Mr. Rajesh Pratap Singh"'''

        data['Driver_Name'] = data['Driver_Name'].apply(lambda x: "Mr. " + captalize_data(x))

        '''create separate column First Name, Middle Name, Last Name and store only names'''

        data['First_Name'] = data['Driver_Name'].apply(name_fun,arg2 = 1)
        data['Middle_Name'] = data['Driver_Name'].apply(name_fun,arg2 = 2)
        data['Last_Name'] = data['Driver_Name'].apply(name_fun,arg2 = 3)

        '''if you found any blank or #N/A then fill it as a "Unknown Driver"'''
        data['First_Name'] = data['First_Name'].apply(fill_null_values,arg2 = 'Unknown Driver',arg3=None)
        data['Driver_Name'] = data['Driver_Name'].apply(fill_null_values,arg2 = 'Unknown Driver',arg3='Mr. Nan')

        ''' In column "transporter name" remove LTD and make the values as Camel Casing
            example : "CORPORATE TRANSPORT LTD" --> it sholud be "Corporate Transport"'''
        data['Transporter_Name'] = data['Transporter_Name'].apply(captalize_data)
        data['Transporter_Name'] = data['Transporter_Name'].apply(lambda x: x.replace('Ltd',''))

        '''if you find any blank values then fill as "Own Trust Transport"'''
        data['Transporter_Name'] = data['Transporter_Name'].apply(fill_null_values,arg2 = 'Own Trust Transport',arg3='Nan')

        '''In "running hours" column fill zero 0 if you find #N/A or blank'''
        data['Running_Hours'].fillna(0 , inplace = True)

        '''(a) In "distance covered(kms)" column fill zero 0 if you find #N/A or blank
        (b) Same for "distance left(kms)"'''
        data['Distance_Covered(Kms)'].fillna(0 , inplace = True)
        data['Distance_Left(Kms)'].fillna(0 , inplace = True)

        '''create a new Column "Total Kms" then fill values as sum of [Distance covered(kms) + Distance left(kms)]'''

        data['Total_Kms'] = data['Distance_Covered(Kms)'] + data['Distance_Left(Kms)']

        '''(a) if you find blank or #N/A in "actual day and time of delivery" fill as "01-01-2022 00:00:01"'''
        data['Actual_Day_And_Time_Of_Delivery'].fillna("01-01-2022 00:00:01",inplace=True)

        '''(b) All the values should be "DD-MM-YYYY HH:MM:SS" and trim the values if you found extra character or no.'''
        data['Actual_Day_And_Time_Of_Delivery'] = data['Actual_Day_And_Time_Of_Delivery'].apply(remove_special_date)
        data['Actual_Day_And_Time_Of_Delivery'] = data['Actual_Day_And_Time_Of_Delivery'].apply(create_date)

        '''(a) In gate_in_date_time format should be "DD-MM-YYYY HH:MM:SS"
            example : "2022-08-06 21:26:32.000+5:30" as "2022-08-06 21:26:32" '''
        
        data['Gate_In_Date_Time'] = data['Gate_In_Date_Time'].apply(remove_special_date1)
        data['Gate_In_Date_Time'] = data['Gate_In_Date_Time'].apply(date_format)
        return data
    
    def transformed_sql_data(data,col_name,id_col):
        data = data[col_name].unique()
        data = pd.DataFrame(data,columns=[col_name])
        data[id_col] = range(1,len(data)+1)
        return data
    
    def merge_data(data1,data2,data3):
        main_df = data1.merge(data2,left_on='Transporter_Name',right_on='Transporter_Name',how='left')
        main_df = main_df.merge(data3,left_on='Driver_Name',right_on='Driver_Name',how='left')
        main_df.drop(['Driver_Name', 'Transporter_Name'],axis=1,inplace=True)
        return main_df



'''Please load the final dataframe to any Database for further task. table name "master_trip_data”'''

class Load_data_to_sql():
    def load_data(transformed_data):
        """ This function loads the final dataframe into the MySQL database.
        You can specify the database connection details in config.ini file.
        The final output will be returned into the database."""
        # creating parser object
        config = configparser.ConfigParser()
        # Reading the config file
        config.read('config.ini')
        host = config['mysql']['host']
        username = config['mysql']['user']
        password = config['mysql']['password']
        port = config['mysql']['port']
        database = config['mysql']['database']
        table_name = config['mysql']['table_name']

        mysqldb=mysql.connector.connect(host=host,user=username,password=password)#established connection   
        mycursor=mysqldb.cursor()#cursor() method create a cursor object 
        mycursor.execute("DROP DATABASE IF EXISTS "+ database)
        mycursor.execute("CREATE DATABASE IF NOT EXISTS "+ database)#Execute SQL Query to create a database  
        mysqldb.close()#Connection Close 
        con = create_engine('mysql+pymysql://'+ username +':'+ password + '@' + host + ':' + port + '/' + database)
        df_to_sql(transformed_data,con,table_name,'replace')
        con.dispose()
    

        drop_table_query = 'DROP TABLE IF EXISTS transporter'
        exicute_sql_query(drop_table_query)
        create_table_query = """CREATE TABLE transporter(
            Transporter_Id INT PRIMARY KEY ,
            Transporter_Name VARCHAR(100)
            )"""

        exicute_sql_query(create_table_query)

        drop_table_query = 'DROP TABLE IF EXISTS driver'
        exicute_sql_query(drop_table_query)
        create_table_query = """CREATE TABLE driver(
            Driver_Id INT PRIMARY KEY ,
            Driver_Name VARCHAR(100)
            )"""
        exicute_sql_query(create_table_query)

        drop_table_query = 'DROP TABLE IF EXISTS aggregate_trip'
        exicute_sql_query(drop_table_query)

        create_table_query = """CREATE TABLE aggregate_trip(
            `Vehicle_Number` VARCHAR(10), 
            `Trip_No` VARCHAR(50), 
            `Plant` VARCHAR(50),
            `Customer` VARCHAR(50),
            `Current_Location` VARCHAR(50), 
            `Running_Hours` double, 
            `Distance_Covered(Kms)`double,
            `Distance_Left(Kms)` double, 
            `Destination` VARCHAR(50), 
            `Actual_Day_And_Time_Of_Delivery` VARCHAR(50), 
            `Gate_In_Date_Time` VARCHAR(50),
            `Latitude` VARCHAR(50),
            `Longitude` VARCHAR(50),
            `First_Name` VARCHAR(50), 
            `Middle_Name` VARCHAR(50), 
            `Last_Name` VARCHAR(50),
            `Total_Kms` double,
            `DRIVER_ID` INT,
            `Transporter_Id` INT ,
            CONSTRAINT fk_driver FOREIGN KEY (Driver_Id) REFERENCES driver(Driver_Id),
            CONSTRAINT fk_transporter FOREIGN KEY (Transporter_Id) REFERENCES transporter(Transporter_Id)
            )"""
        exicute_sql_query(create_table_query)

    def save_table_to_sql(data,table_name):
        config = configparser.ConfigParser()
        config.read('config.ini')
        host = config['mysql']['host']
        username = config['mysql']['user']
        password = config['mysql']['password']
        port = config['mysql']['port']
        database = config['mysql']['database']
        con = create_engine('mysql+pymysql://'+ username +':'+ password + '@' + host + ':' + port + '/' + database)
        df_to_sql(data,con,table_name,'append')
        con.dispose()


if __name__ == '__main__': 

    df = Extract_data.source_data()
    print("********** Data Extracted Successfully ***********")
    transformed_data = Transformations.source_transformations(df)
    print("********** Data Transformed Successfully ***********")
    Load_data_to_sql.load_data(transformed_data) #
    print("********** Source Data Loaded Successfully ***********")
    df_source = Extract_data.sql_data('master_trip_data')
    transporter = Transformations.transformed_sql_data(df_source,'Transporter_Name','Transporter_Id')
    driver = Transformations.transformed_sql_data(df_source,'Driver_Name','Driver_Id')
    # aggregate_trip = pd.DataFrame(Transformations.merge_data(df_source,transporter,driver))
    # Load_data_to_sql.save_table_to_sql(transporter,'transporter')
    # Load_data_to_sql.save_table_to_sql(driver,'driver')
    # Load_data_to_sql.save_table_to_sql(aggregate_trip,'aggregate_trip')
    # print("************* Data loaded Successfully **************")

