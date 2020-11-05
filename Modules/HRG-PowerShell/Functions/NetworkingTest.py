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
Suite500 = {
    'device_type': 'cisco_ios',
    'host': '172.30.254.213',
    'username': user,
    'password': pwd,
}
#setup the connection to the device within a session 'net_connect'
net_connect = ConnectHandler(**Suite500)
#Send a command to the device, and store in 'result'
result = net_connect.send_command("show ip int brief", delay_factor=2, use_textfsm=True)
#Disconnect from the device
net_connect.disconnect()

print(result)