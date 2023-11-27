---
date: <%tp.file.title%>
creation date: <% tp.file.creation_date() %>
modification date: <% tp.file.last_modified_date("Y HH:mm:ss") %>
tags:
  - "#DailyNote"
Run: false
Row: false
Lift: false
---
[[<% tp.date.now("YYYY-MM-DD") %>]] 

Autoset a tag based on the title, v1.0
<%* let type = tp.file.title; name = (type.includes("Meeting")) ? "\"\#Meeting\"" :(type.includes("Project")) ? "\"\#Project\"" : (type.includes("Request")) ? "\"\#Request\"" :(type.includes("Research")) ? "\"\#Research\"" : ""; tR += name %>

<%* let type = tp.file.title;
// Find the position of the third '-' occurrence
thirdDashIndex = type.indexOf('-', type.indexOf('-', type.indexOf('-') + 1) + 1);

// Find the position of the fourth '-' occurrence
fourthDashIndex = type.indexOf('-', thirdDashIndex + 1);

// Extract the substring from the third '-' to the fourth '-'
extractedString = fourthDashIndex !== -1 ? type.substring(thirdDashIndex + 1, fourthDashIndex) : type.substring(thirdDashIndex + 1);

// Replace spaces with '/' and create the final name
name = extractedString.replace(/\s+/g, '/') ? `\"#${extractedString.replace(/\s+/g, '/')}\"` : "";
tR += name %>


# tp.config

# tp.file
Grabs the title of the file
<% tp.file.title %>
To automatically set the cursor in a specific place when the template is opened
<% tp.file.cursor() %>
Script to grab the title when a new file is created
<%*
	let title = tp.file.title 
	if (title.startsWith("Untitled")) {
		title = await tp.system.prompt("Title");
		await tp.file.rename(`${title}`);
	}
%>
# <%* tR += `${title}` %>

Sample Code---
`<%* let day =` [tp.date.now](https://tp.date.now)`("dd")`

`if ((day != "Sa") && (day != "Su")) { %>`

`# Agenda`

`<%* } else { %>`

`<%* } %>`
---
# tp.date 
# tp.frontmatter

# tp.hooks

# tp.obsidian

# tp.system

# tp.web


Search "replace"
	replace templates in the active file
	<% tp.date.now("YYYY-MM-DD")%> - <% tp.file.title %>

<% tp.user.script("Hey there") %>

setup a template to create a new file within a specific folder, and then leverage a link to possibly automatically create a new file within a folder with the desired name and meta data
<< [[Daily/Notes/<% await moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<% await moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('MM')%>/<% await moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD").format('WW') - - 1%>| LastWeek]] 

- <% await tp.file.title %> - [[Daily/Notes/<% await moment(tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")).format('YYYY')%>/<% await moment(tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")).format('MM')%>/<% await tp.date.now("YYYY-MM-DD",1,tp.file.title,"YYYY-MM-DD")%>|NextWeek]] >>


---
<%*

let type, name, topic, held
held = tp.date.now("YYYY-MM-DD")
topic = "o "
type = await tp.system.suggester(["with a specific person", "meeting with a custom name", "no specific people nor names"], ["with a specific person", "meeting with a custom name", "no specific people nor names"], false, "What kind of meeting it was?")

if (type == "with a specific person") name = await tp.system.prompt("What was their first and second name?", "with ", true, false)
else if (type == "meeting with a custom name") name = await tp.system.prompt("What was the meeting called then?", "", true, false)
else if (type == null || type == "no specific people nor names") name = "" 

topic = await tp.system.prompt("What was the meeting about?", "about ", true, false)
if (topic == "about ") topic = ""

let final_name = name
if (name.length > 0) final_name += " "

let triggered_date = tp.date.now("YYYY-MM-DD", 0, tp.file.title, "YYYY-MM-DD")
if (held != triggered_date) {
	if (await tp.system.prompt("You triggered this meeting in a note from " + triggered_date + ". Do you want to use this date instead of today's? y / ESC", false, false, false) == "y") held = triggered_date
}

final_name += topic + " - " + held

tR += "!\[\[" + final_name + "\]\]"
tp.file.create_new(tp.file.find_tfile("new meeting"), final_name, true, app.vault.getAbstractFileByPath("meetings"))

%>

---

<%*if (tp.file.title contains "Meeting") name = "#Meeting" else if (type == "meeting with a custom name") name = await tp.system.prompt("What was the meeting called then?", "", true, false) else if (type == null || type == "no specific people nor names") name = "" tR += name%>