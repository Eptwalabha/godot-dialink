# Dialink
A Godot 3.2 plugin to easily handle dialogs in your game

## What this plugin isn't
- A node to display dialogs
- A dialog editor

## Then what is it for?
This plugin is useful if your game needs to handle multiple dialogs with multiple choices (or simple linear dialog as well ;) ), it event handles conditional branching.
The new `DialogSystem` node will handle the logic of your dialogs by returning what to display next.  
Once your dialogs are defined in the new node, you'll just have to call:
``` GDscript
my_dialog_system.start("my-dialogt")
var current_dialog = my_dialog_system.next()
# or if the dialog offers multiple choices
var current_dialog = my_dialog_system.choice_next(user_choice)
```

# Licence
`Dialink` is provided under the MIT License.

# Install
Download / clone the project somewhere on your computer
``` bash
git clone git@github.com:Eptwalabha/godot-dialink.git
```
Then copy the `addons/dialink` directory into the `addons` directory of your project.  
Finaly, activate the plugin `Project`>`Project Settings`>`Plugins`.

# How to
Once the plugin is activated, you should see a new `DialogSystem` node in the node list with the following icon:
[!dialink icon](https://raw.githubusercontent.com/Eptwalabha/godot-dialink/master/icon.png)
Add it to your Scene (If needed, you can add more).  
In order to work, you need to provide to the new node with a JSON file where all your dialogs are defined.

# Example:
See [Simple.gd](https://github.com/Eptwalabha/godot-dialink/blob/master/Simple.gd) to have an idea on how to use the node.

# Structure of the JSON file
I'm currently working on a Wiki to explain how to write your dialogs.  
That said, if you're not afraid of diving in the code, you should check all the unit tests.  
The JSON file [example.json](https://github.com/Eptwalabha/godot-dialink/blob/master/example.json) is also a nice place to start
