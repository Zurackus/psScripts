#Python networking Test
#Must netmiko, textfsm, getpass, 
import textfsm
from netmiko import ConnectHandler
import getpass
#Pulls the local username
user = getpass.getuser()
#Prompts for the password
pwd = getpass.getpass('Password:')
#Store the device information
ASA_VPN = {
    'device_type': 'cisco_ios',
    'host': '192.168.205.3',
    'username': user,
    'password': pwd,
    'secret' : pwd,
}
#setup the connection to the device within a session 'net_connect'
net_connect = ConnectHandler(**ASA_VPN)
#elavate to enabled mode
net_connect.enable()
#Send a command to the device, and store in 'result'
result = net_connect.send_command("show vpn-sessiondb detail l2l")# ,use_textfsm=True
#Disconnect from the device
net_connect.disconnect()

print(result)