from bs4 import BeautifulSoup
import requests

url ="https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/securityevent"
content = requests.get(url)
soup = BeautifulSoup(content.content, "html.parse")

content = soup.findAll('div', attrs={"class": "content"})
for x in content:
 print(x.find('p').text)