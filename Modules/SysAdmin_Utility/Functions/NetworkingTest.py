#Python networking Test
#Must netmiko, textfsm, getpass, 
import textfsm
from netmiko import ConnectHandler
import getpass
import pandas as pd
import datetime

    #Pulls the local username
user = getpass.getuser()
    #Prompts for the password
pwd = getpass.getpass('Password:')
    #Store the device information
ASA_VPN = {
    "device_type": "cisco_asa_ssh",#"cisco_ios"
    "host": "192.168.205.3",
    "username": user,
    "password": pwd,
    "port" : 22,
    "secret" : pwd,
    "global_delay_factor" : 3,
}
print ('\n### Connecting to the ASA ###')
    #Command being sent to the network device
command = ' show running-config tunnel-group'

    #setup the connection to the device within a session 'net_connect'
with ConnectHandler(**ASA_VPN) as net_connect:
    #elavate to enabled mode
    net_connect.enable()
    #Send a command to the device, and store in 'result'
    print(net_connect.find_prompt())
    result = net_connect.send_command(command, use_textfsm=True)#,delay_factor=2

print(result)

print('\n##################################################\n')
    #Convert to Pandas Data Frame
firstDF = pd.DataFrame.from_dict(result)
    #Identifying the columns to keep from the data
cols_to_keep = ['name']
    #Filtered Data Frame
secondDF = firstDF[cols_to_keep]
#uniquePeers = secondDF['connection'].unique()
secondDF.insert(1,'Date',datetime.datetime.today().strftime('%m/%d/%Y'))
ciscoDF = secondDF.drop_duplicates('connection',keep='first')
    #Open the original csv with existing data
ciscoDF.to_csv('TunnelGroups.csv',index = False)
print('Done')
print('\n##################################################\n')