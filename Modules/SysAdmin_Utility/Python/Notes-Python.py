#Script to import missing modules
import sys
import subprocess
import pkg_resources

required = {'mutagen', 'gTTS'}
installed = {pkg.key for pkg in pkg_resources.working_set}
missing = required - installed

if missing:
    python = sys.executable
    subprocess.check_call([python, '-m', 'pip', 'install', *missing], stdout=subprocess.DEVNULL)

from os import path
workfiles = path.expandvars(r'%LOCALAPPDATA%\WorkFiles')