---
date: <%tp.file.title%>
modification date: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
tags:
  - DailyNote
Lift: 
Run: 
Row:
---
<< [[Daily/Notes/<%moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('MM')%>/<%tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")%>| Yesterday]] - <%tp.date.now("dddd",0,tp.file.title,"YYYY-MM-DD")%> - [[Daily/Notes/<%moment(tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%moment(tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")).format('MM')%>/<%tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")%>|Tomorrow]] >>
# Linked Action Summaries
```dataview
TABLE keyNote
FROM outgoing([[]])
WHERE contains(file.name, " - ")
```

# Daily Actions
Action:: 
BackBurner:: 
# Daily Side Notes
Amtrak::
AmtrakLink::
Sentinel::
SentinelLink::
KQL::
KQLLink::
Research::
ResearchLink::
Defender::
DefenderLink::