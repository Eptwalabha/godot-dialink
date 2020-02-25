# Dialink :D![dialink icon](https://raw.githubusercontent.com/Eptwalabha/godot-dialink/master/icon.png)  
A Godot 3.2 plugin to easily handle dialogs in your game.

# What this plugin isn't
- This plugin **is not** a Node2D nor a Control node that will display dialogs
- This plugin **is not** (yet) a dialog editor

# Then what is it?
This plugin is useful if your game needs to handle multiple dialogs with multiple choices and/or conditional branching (it also handles simple linear dialog as well ;) ).  
Under the hood, the new `DialogSystem` node will take care of the logic of your dialogs.  
Once everything's set up, you just have to ask the node what to display next.  
# Install
## From github:
Download / clone the project somewhere on your computer
``` bash
git clone git@github.com:Eptwalabha/godot-dialink.git
```
Then copy the `addons/dialink` directory into the `addons` directory of your project.  
Finaly, activate the plugin `Project`>`Project Settings`>`Plugins`.

## From the Godot asset library
The plugin is available [here](https://godotengine.org/asset-library/asset/543).  
1. Directly from the godot editor, open the `AssetLib` and search for `Dialink` under the `Tools` category.  
2. Once the plugin's popup is opened, click `download` then `install`.
3. The `Package Content` popup should open, uncheck everything but the `addons/dialink` directory and its content (if you skip this step, you might end up with unwanted scenes/tests).
4. Click `ok`
5. activate the plugin `Project`>`Project Settings`>`Plugins`.

You can now access the new `DialogSystem` node.

# Quick tutorial

## Add the new `DialogSystem` node to your scene:
Once the plugin is activated, you should see a new `DialogSystem` node in the node list with the following icon:  
![dialink icon](https://raw.githubusercontent.com/Eptwalabha/godot-dialink/master/icon.png)  
Add it to your Scene (you can add more than one).  

## Set up the new node
In order to work, you need to provide the new node with a JSON file where all your dialogs are defined.
For the sake of this tutorial, we'll use the following JSON file (`my-simple-dialog.json`):
``` json
{
    "dialogs": {
        "hello-world": [
            {
                "text": "Hello my friend."
            },
            {
                "text": "How are you?",
                "choices": [
                    {
                        "text": "Fine, and you?",
                        "then": [
                            { "text": "Very well" }
                        ]
                    },
                    {
                        "text": "I'm not feeling very well today",
                        "then": [
                            { "text": "Too bad" }
                        ]
                    }
                ]
            }
        ]
    }
}
```
Setting up a new node is as simple as:
``` gdscript
var dialogs = $DialogSystem
# set up the json file containing all your game dialogs
# (this can also be done directly from the editor's inspector)
dialogs.dialog_file = 'res://my-simple-dialog.json'
# let start the dialog named 'hello-world'
dialogs.start("hello-world")
```
That's it, you're all set up!

## Let's chat a bit  
If you want to know what dialog to display next, just call the `next()` function:
``` gdscript
var dialog_content = dialogs.next()
```
This will return a `Dictionary` containing the current line of dialog to display on screen.
``` gdscript
{
    'text': "Hello my friend."
}
```
In this example, calling `next()` again will return the choices you need to display to your player:
``` gdscript
{
    'text': "How are you?",
    'choices': [
        {
            'id': 0,
            'text': "Fine, thank you"
        },
        {
            'id': 1,
            'text': "I'm not feeling very well today"
        }
    ]
}
```
Call the `choice_next(id)` function once your player has choosen what to answer:
``` gdscript
# let's say the player picked the second choice with the `id` = 1
dialog_content = dialogs.choice_next(1)
```
Now `dialog_content` contains the next line of dialog to display:
``` gdscript
{
    "text": "Too bad"
}
```

This is only a simple example, this node can do much much more

# Licence
`Dialink` is provided under the MIT License.

