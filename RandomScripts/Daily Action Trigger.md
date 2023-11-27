<%*
//Here is where the categories are managed
let held = tp.date.now("YYYY-MM-DD", 0, tp.file.title, "YYYY-MM-DD")
const categories = ["Meeting","Request","Project","Research"]
//This is where the question for the categories is posed
let type = await tp.system.suggester(categories, categories, true, "What kind of action is it?")
//Here is where the subcategories are managed
const subcategories = ["Amtrak","Trustwave","Personal","Other"]
//This is where the question for the subcategories is posed
let type2 = await tp.system.suggester(subcategories, subcategories, true, "Subcategory?")
//Just a placeholder if no Title is provided
let topic = "o "

let year = moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('YYYY')
let month = moment(tp.date.now("YYYY-MM-DD",-1,tp.file.title,"YYYY-MM-DD")).format('MM')
let location = "Daily\/Actions\/" + year + "\/" + month + "\/"

topic = await tp.system.prompt("Title for action:", "", true, false)
//Fallback Title if none is provided
if (topic == "o ") topic = ""
//Constructing the 'name' of the file link
final_name = held + " -" + type + " " + type2 + "- " + topic
//Building out the full path, file name, and then the shortened version of the link name
tR += "\[\[" + location + final_name + "\|" + final_name + "\]\]"
%>