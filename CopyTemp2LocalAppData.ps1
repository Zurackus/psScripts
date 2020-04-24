#Script to copy all of the Templates out to your local App Data folder

Copy-Item -Path "\\hrgatad\I\IT_CommunicationsTemplate\Templates\*" -Destination "C:\Users\$env:username\AppData\Roaming\Microsoft\Templates\" -Recurse