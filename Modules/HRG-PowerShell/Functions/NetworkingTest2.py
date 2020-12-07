#Python networking Test
#Must netmiko, textfsm, getpass, 
import textfsm
from netmiko import ConnectHandler
import getpass
import csv

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
    "secret" : pwd,
    #"global_delay_factor": 1,
}
print ('\n### Connecting to the ASA ###\n')
#setup the connection to the device within a session 'net_connect'
#net_connect = ConnectHandler(**ASA_VPN)
#show vpn-sessiondb detail l2l (sh vpn- de l2)
#show int ip brief
command = 'show vpn-sessiondb detail l2l'

with ConnectHandler(**ASA_VPN) as net_connect:
    #elavate to enabled mode
    net_connect.enable()
    #Send a command to the device, and store in 'result'
    net_connect.find_prompt()
    result = net_connect.send_command(command,use_textfsm=True)#,delay_factor=3

l = len(result)

#for i in range (0,l):
#    str(result[i]['connection']) + ' ' + result[i]['protocol'])

print('\n##################################################')
for i in range (0,l):
    print(result[i]['connection'] + ' ' + result[i]['protocol'])