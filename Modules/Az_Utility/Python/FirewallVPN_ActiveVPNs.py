#Python networking Firewall
#Must netmiko, textfsm, getpass, pandas
import textfsm #allows the handling of the information output 
from netmiko import ConnectHandler
import getpass
import pandas as pd #to read/manipulate JSON output
import datetime
from os import path

    #Auto pulls the local username of the account who started this script
user = getpass.getuser()
    #Prompts for the password
pwd = getpass.getpass('Password:')
    #Store the device information you are connecting to
ASA_VPN = {
    "device_type": "cisco_asa_ssh",#"cisco_ios"(for a switch)
    "host": "192.168.205.3",#Management IP of the device you are connecting to
    "username": user,
    "password": pwd,
    "port" : 22,
    "secret" : pwd,
    "global_delay_factor" : 3, #May not be needed
}

print ('\n### Connecting to the ASA ###')
    #Command being sent to the network device
command = ' show vpn-sessiondb detail l2l'

    #setup the connection to the device within a session 'net_connect'
with ConnectHandler(**ASA_VPN) as net_connect:
    #elavate to enabled mode
    net_connect.enable()
    #Send a command to the device, and store in 'result'
    net_connect.find_prompt()
    result = net_connect.send_command(command, use_textfsm=True)

print('\n##################################################\n')
    #Convert to Pandas Data Frame
firstDF = pd.DataFrame.from_dict(result)
    #Identifying the columns to keep from the data
cols_to_keep = ['connection','protocol']
    #Filtered Data Frame
secondDF = firstDF[cols_to_keep]
    #Adding a 'Date' Column to the Dataframe, and setting it to the current date
secondDF.insert(2,'Date',datetime.datetime.today().strftime('%m/%d/%Y'))
    #Dropping any Duplicate Peer addresses in 'connection' column
ciscoDF = secondDF.drop_duplicates('connection',keep='first')
    #Setting the path for where the output file will be
workfiles = path.expandvars(r'%LOCALAPPDATA%\WorkFiles')
    #Open the original csv with existing data
csvOpen = pd.read_csv(workfiles+"\ciscoDF.csv")
    #Merging the existing csv data with the new 'CiscoDF' pulled today into a single DataFrame
final = pd.concat([csvOpen,ciscoDF])
    #Converting the 'final' data from to a csv, overwriting the old one
final.to_csv(workfiles+'\ciscoDF.csv',index = False)
print('Done')
print('\n##################################################\n')