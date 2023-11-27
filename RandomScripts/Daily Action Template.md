---
date: <%tp.file.title%>
modification date: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
time: .5hr
tags:
  - "#DailyAction"
  - <%* let type = tp.file.title; thirdDashIndex = type.indexOf('-', type.indexOf('-', type.indexOf('-') + 1) + 1); fourthDashIndex = type.indexOf('-', thirdDashIndex + 1); extractedString = fourthDashIndex !== -1 ? type.substring(thirdDashIndex + 1, fourthDashIndex) : type.substring(thirdDashIndex + 1); name = extractedString.replace(/\s+/g, '/') ? `\"#${extractedString.replace(/\s+/g, '/')}\"` : ""; tR += name %>
---
keyNote:: 
## Notes:
	
## Tasks:
- [ ] 
