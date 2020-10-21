#Script to copy all of the Templates out to your local App Data folder

Copy-Item -Path "\\hrgatad\i\IT_CommunicationsTemplate\Templates\*" -Destination "$ENV:UserProfile\AppData\Roaming\Microsoft\Templates\" -Recurse

pause