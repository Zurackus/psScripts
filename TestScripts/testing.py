import pySigma

plugins = pySigma.get_available_plugins()

for plugin in plugins:
    print(plugin)