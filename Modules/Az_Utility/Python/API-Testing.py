import requests
import json

URL = "https://jsonplaceholder.typicode.com/users"

response = requests.get(URL)

print(response.text)

userdata = json.loads(response.text)[0] #Single user to be returned

name = userdata["name"]
email = userdata["email"]
phone = userdata["phone"]

