# Overview
**avg.NET** is a framework for creating a **command selecting style adverture game** using
 - ASP.NET
 - Javascript
 - MySQL database

You can create your own game only by preparing
- some database records
- HTML files and image files for each scenes in your game
- some Javascript functions for special events (only if needed)

# Sample adventure game
- [Japanese](http://avgnet-env.eba-kdrwuz2p.us-west-2.elasticbeanstalk.com/scenes/00001.html)
- [English](http://avgnet-en-env.us-west-2.elasticbeanstalk.com/scenes/00001.html)

# Getting started
First, clone this repository.  

## How to run the sample game locally
If you have [Docker](https://www.docker.com/) on your PC, you can run the sample game shown above, simply by executing the command  
`docker compose -f "docker-compose.yaml" up -d --build`  
at the repository root. (In English, use 'docker-compose-en.yaml' instead.)

Then visit this URL on your browser.  
http://localhost/scenes/00001.html

## Development
You can develop your own game using 'docker compose' as discribed above.  
But you can also debug the game as ordinary ASP.NET web application, using .NET SDK with [Visual Studio](https://visualstudio.microsoft.com/) or [Visual Studio Code](https://azure.microsoft.com/en-us/products/visual-studio-code/).  
In that case, you need MySQL5.7 database server (locally or as a Docker container).

### If you run the database server separately (not using *docker compose*)
You need
 1. to set MySQL server character set to 'utf8mb4' and collation to 'utf8mb4_general_ci' (only if you use non ascii characters).
 1. to create database, tables, and records. 
 1. to modify the 'ConnectionString' section in 'appsettings.json' to connect your database server.

## Environment
- .NET6.0 SDK
- MySQL 5.7

# Folders
## Controllers
C# sources for ASP.NET Core web api.  
Usually, you don't need to modify them. But feel free to do it if needed.

## mysql-setting
There are two folders, *initdb.d* and *initdb.en.d*.  
And there is a file named *init-avg-db.sql* in each folders.  
*init-avg-db.sql* is a script file for creating database, tables, and insering data to MySQL database.  
The file in *initdb.d* folder is for Japanese, in *initdb.en.d* is for English.

If you run the application with 'docker compose', the scrpt will automatically be executed in the MySQL Container.  
But If you have the database server separetely, you may need to execute script yourself.

## wwwroot
the root folder of The static files.
### scenes
The folder for HTML files for each scenes.  
Each HTML files should have links to related image files in *img* folder.  
And some HTML files may have links to related Javascript files in *scene-js* folder.
### img
The folder for image files for each scenes.
### scene-js
The folder for Javascript files for each scenes.  
Not all HTML file have to have specific Javascript file.  
But if you need a special event in a scene, and that needs some addtional Javascript function,  
create a .js file in this folder, and write functions, then add a link to it in the HTML file of the scene.  
(This relates the EVENT column of the MESSAGE table, so check the discription show below)
### avs.js
Core Javascript program of this framework.  
Usually, you don't need to modify them. But feel free to do it if needed.
### avg.css
CSS file of this framework.
Usually, you don't need to modify them. But feel free to do it if needed.
# Flag
Understanding the concept of **flag** is important for using this framework.  
Flag is the value represents the player's state.  
It is a 64 bit unsigned inetger, but used as a binary.

If you define the flag value 8 (1000 in binary) that represents whether the player has a specific item or not,  
the framework judges it by executing AND logical operation between the item's flag value and the player's flag value.
If the result is equal to the item's flag, then the player has the item.

Example:
- Player's flag is 42 (101010 in binary), 101010 AND 1000 = 1000, then the player has it.
- Player's flag is 34 (100010 in binary), 100010 AND 1000 = 0, then the player don't.

The initial value of player's flag is 0.

# Tables
Understanding the concepts of each tables is also important for using this framework.  
Definitions of each tables are discribed in *mysql-setting/initdb.d/init-avg-db.sql* as CREATE TABLE statements.  
So, only summaries of each tables are described below.

## SCENE
Scene is a set of id and path of the scene.  
PATH column should have a relative path to its HTML file from *wwwroot*.  
This table also have FLAG column, but it's not used now.

## COMMAND
Command is a thing the player can do at the scene.

The records those have specific SCENE_ID are the things the player can do only at the scene.  
And the records those have SCENE_ID = '00000' are common commands (e.g. use, check) the player can do at all scenes.  
So, at a scene, both the common commands and the scene specific commands are shown to the player.

## TARGET
Target is a thing can be a target of the command the player selects.  
When the player is in a room at a scene, and if the player selects the command 'check', the targets may be the stuff in the room. (ex. chair, table, bed ...)

The column FLAG is the condition whether the target is shown or not. It is judged by a logical operation discribed the 'Flag' section.

When the player has the flag value 20 (10100 in binary), a record of TARGET table has FLAG = 4 (100 in binary) is shown.  
But a record that has FLAG = 8 (1000 in binary) is not shown.

If the FLAG of the record is NULL, then the target is always shown at the scene. 

The column DEST_SCENE_ID is specific of the COMMAND_ID: 'GOT' (the command to go to another scene).  
And it is the SCENE_ID the player go to.

## MESSSAGE
Message is a text shown to the player as the result of the command executed to the target or is a text that prompts the player to select a target of the command.

### FLAG, SET_FLAG, UNSET_FLAG columns
The column FLAG is the condition whether the message is shown, same as the FLAG coulumn of the TARGET table discribed above.  
The column SET_FLAG is the flag value added to the player's flag when the message is shown.  
UNSET_FLAG is the opposite, the flag value subtracted from the player's flag when the message is shown.

### Player's flag value before and after a message is shown
|                     | decimal  | binary |
|:--------------------|---------:|-------:|
| player's flag value (before the message is shown) | 20       |  10100 |
| SET_FLAG value of the message         | 4        |  01000 |
| UNSET_FLAG value of the message        | 8        |  00100 |
| ---------------------- | -------- | ------ |
| player's flag value (after the message is shown)  | **24**       |  11000 |

### EVENT column
The column EVENT is the name of Javascript function should be executed when the message is shown.  
If the EVENT column has the value 'getCommands', and the message is shown, the Javascript code *getCommands()* needs to be resolved by the browser's Javascript runtime.  
So, the function need to be defined in the *avg.js* or in the scene specific .js file in the *scene-js* folder.  
(The function 'getCommands()' is defined in *avg.js*, so it doesn't need specific .js file.)

### TEXT column
The text content of the message.  

TEXT has some control characters shown below.
| control character           | meaning  |
|:-------------------:|:---------|
|^| The point that the associated event should be executed |
|@| Begin a new line |
|;| Stop showing the message at this point, and show the link button to continue | 


For example, if the TEXT value is 'Hello@world!;Hello avg!^',  
at first,  
```
Hello
world!
▼
```
is shown. ▼ is the link button. 
The player clicks the ▼,  
```
Hello avg!
```
is shown.  
Then, the associated event (defined in EVENT column) is executed, because the TEXT value has a '^' character at the end.  

There are no escape sequences for these control characters. So you can't use them as a part of message content.  
But still useful for showing the messages more readably.

### Initial message of the scene
Initial message of the scene is the message shown when the player come to the scene.  
And it is the record of the MESSSAGE table that has
- SCENE_ID: id of the scene and
- COMMAND_ID: '000' and
- TARGET_ID: '000'

Tipicaly, it is the message that tells the player where he/she is.  
(For example: '*You are at home*.', '*You are at the station*.')  
Initial messages have it's flag value. So, you can change initial message of the scene by the player's flag value.  

Usually, when the initial message of a scene is shown, It is need to show the top level commands.  
So, **initial message records often have 'getCommands' as it's event**.  

### Initial message of the command
Initial message of the command is the message shown when the player select a command.  
It is the message that prompts the player to select a target of the command to be executed to.  
For example: '*Check what?*'. '*Go where?*'.  
And it is the record of 'message' table that has
- SCENE_ID: '00000' and
- COMMAND_ID: id of the command the player selected. and
- TARGET_ID: '000'

### Default message of the command
Default message of the command is the message shown when the command the player selected has no target.  
It is the message that tells the player the command has no target here. (For example: '*There is nothing to check here.*')  
And it is the record of `message` table that has
- SCENE_ID: '00000' and
- COMMAND_ID: id of the command the player selected. and
- TARGET_ID: '999'

# Person Mode
*Person mode* is also important feature of this framework.  
If the player is with a person at a scene, the person's image should be shown overlaid on the background image of the scene.  
And the player can select only *person commands*. (ex. show something to the person, talk about something with the person)  
That is the *person mode*.

First, you have to prepare the person's image. that should have transparent background.  
To set the *person mode*, you have to add a *img* DOM element for the person's image.  
The element have to have a css class '*img-person1*', and have to be appended in the element that has id: '*image-area*'.  
(Now only *img-person1* class is in avg.css. But feel free to add *img-person2* if needed.)

Then, you need to execute the Javascript function *setPersonMode(person_flag)*.  
Pass the value that you can identify the person from it as the argument.

To unset the *person mode*, remove the *img* element, end execute the function *setPersonMode('')*.  
The argument is empty string.

See the *wwwroot/scene-js/00002.js* for example of setting and unsetting *person mode*.

