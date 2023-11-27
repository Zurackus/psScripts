<< [[Daily/Review/Monthly/<%moment(tp.date.now("YYYY-MM","P-1M",tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%tp.date.now("YYYY-MM","P-1M",tp.file.title,"YYYY-MM-DD")%>-01| LastMonth]] - <%tp.date.now("YYYY-MM-DD",0,tp.file.title,"YYYY-MM-DD") %> - [[Daily/Review/Monthly/<%moment(tp.date.now("YYYY-MM","P1M",tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%tp.date.now("YYYY-MM","P1M",tp.file.title,"YYYY-MM-DD")%>-01|NextMonth]] >>

```dataview
TABLE highlights
FROM "Daily/Notes/<%moment(tp.date.now("YYYY-MM-DD",0,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<%moment(tp.date.now("YYYY-MM-DD",0,tp.file.title,"YYYY-MM-DD")).format('MM')%>"
WHERE highlights != null
SORT file.day
```

```dataview
TABLE update, date, time, tags
FROM "Daily/Notes"
WHERE file.day >= date(2023-11-11)
AND file.day <= date(2023-11-17)
```



AND file.day.year = number(substring(string(this.file.name),0,4))
AND file.day.weekyear = number(substring(string(this.file.name),6,8))
