---
date: <%tp.file.title%>
modification date: <% tp.file.last_modified_date("Y HH:mm:ss") %>
tags:
  - "#WeeklySummary"
---
<< [[Daily/Review/Weekly/<%moment(tp.date.now("YYYY-MM-DD",-7,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%tp.date.now("YYYY-MM-DD",-7,tp.file.title,"YYYY-MM-DD")%>| LastWeek]] - <%tp.date.now("YYYY",0,tp.file.title,"YYYY-MM-DD") %>-W<% tp.date.now("WW",0,tp.file.title,"YYYY-MM-DD") - -1%> - [[Daily/Review/Weekly/<%moment(tp.date.now("YYYY-MM-DD",7,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%tp.date.now("YYYY-MM-DD",7,tp.file.title,"YYYY-MM-DD")%>|NextWeek]] >>
# Actions from the Week
```dataview
TABLE Action
FROM "Daily/Notes"
WHERE Action != null
AND file.day >= date(<%tp.date.now("YYYY-MM-DD",-7,tp.file.title,"YYYY-MM-DD")%>)
AND file.day <= date(<%tp.date.now("YYYY-MM-DD",0,tp.file.title,"YYYY-MM-DD")%>)
SORT file.day
```
# BackBurner from the Week
```dataview
TABLE BackBurner
FROM "Daily/Notes"
WHERE BackBurner != null
AND file.day >= date(<%tp.date.now("YYYY-MM-DD",-7,tp.file.title,"YYYY-MM-DD")%>)
AND file.day <= date(<%tp.date.now("YYYY-MM-DD",0,tp.file.title,"YYYY-MM-DD")%>)
SORT file.day
```

