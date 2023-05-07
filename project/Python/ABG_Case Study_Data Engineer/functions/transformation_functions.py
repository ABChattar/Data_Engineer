import numpy as np
import pandas as pd
import re
from datetime import datetime

def captalize_data(st):
    st = str(st)
    st= st.title()
    print(st)
    return st

def remove_special_char(st):
    new_st = ''
    for i in st:
        if i== '/' or i.isnumeric():
            new_st += i
    new_st = 'HIL-DA-' + new_st
    return new_st

def vehicle_number():
    list_no=[]
    for i in range(1,101):
        list_no.append('VEH_'+("{:03d}".format(i)))
    return list_no

def fill_null_values(data,arg2,arg3):
    if data == arg3 or data == '#N/A' or data == 'Null' or data == 'Nan' or data == None:
        return arg2
    else:
        return data
    
def name_fun(st, arg2):
    st = st.replace(".", "")
    name = st.split(' ')
    if len(name) < arg2+1:
        return None
    else:
        return name[arg2]
    
def remove_special_date(st):
    new_st = ''
    for i in st:
        if i in [':','-',' '] or i.isnumeric():
            new_st += i
    new_st = re.search(r'\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}', new_st)
    new_st = new_st.group()
    return new_st

def create_date(st):
    st = st.split(".")[0]
    st = datetime.strptime(st, "%d-%m-%Y %H:%M:%S")
    output_str = st.strftime("%d-%m-%Y %H:%M:%S")
    return output_str
    
def date_format(st):
    st = st.split(".")[0]
    st = datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    output_str = st.strftime("%d-%m-%Y %H:%M:%S")
    return output_str

def remove_special_date1(st):
    new_st = ''
    for i in st:
        if i in [':','.','-',' '] or i.isnumeric():
            new_st += i
    return new_st