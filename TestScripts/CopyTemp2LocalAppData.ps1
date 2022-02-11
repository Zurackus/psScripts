#Script to copy all of the Templates to your local App Data folder

Copy-Item -Path "\\hrgatad\I\IT_CommunicationsTemplate\Templates\*" -Destination "C:\Users\$env:username\AppData\Roaming\Microsoft\Templates\" -Recurse

Copy-Item -Path "\\hrgatad\i\IT_CommunicationsTemplate\Templates\*" -Destination "$ENV:UserProfile\AppData\Roaming\Microsoft\Templates\" -Recurse
