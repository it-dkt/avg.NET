# Latest Version
The latest version is 2.7.

- 2.7
  - title page (*wwwroot/index.html*) shown at `/`
  - updated sample game
- 2.6
  - background music
  - scroll in command area
- 2.5
  - save/load
  - multiple events in one message
- 2.0
  - changed table schema

Versions 2.0 and later are not compatible with 1.0.

# Overview
**avg.NET** is a framework for creating a **command-selection style adventure game** using
 - ASP.NET
 - JavaScript
 - MySQL database

You can create your own game just by preparing
- some database records
- HTML files and image files for each scene in your game
- some JavaScript functions for special events (only if needed)

> **More games made with avg.NET are published at [it-dkt.github.io](https://it-dkt.github.io/).**

# Getting started
First, clone this repository.  

## How to run the game locally
If you have [Docker](https://www.docker.com/) on your PC, you can run the game by executing the command  
`docker compose -f "docker-compose.yaml" up -d --build`  
at the repository root.

Then visit this URL in your browser.  
http://localhost

The title page (*wwwroot/index.html*) will be shown.  
Static files are copied into the image at build time, so run the command again with `--build` after editing files in *wwwroot*.

### Resetting the database
The script *init-avg-db.sql* runs only when the MySQL container starts with an empty database.  
The database is kept when you run `docker compose up` again, even with `--build`.  
So after editing *init-avg-db.sql*, remove the containers and the database volume first, then start again:  
`docker compose -f "docker-compose.yaml" down -v`  
`docker compose -f "docker-compose.yaml" up -d --build`

(Save data is stored in the browser's local storage, not in the database, so it is not cleared by this.)

> Note: *docker-compose-en.yaml* loads the English data in *mysql-setting/initdb.en.d*.

# Development
You can develop your own game using *docker compose* as described above.  
But you can also debug the game as an ordinary ASP.NET web application, using the .NET SDK with [Visual Studio](https://visualstudio.microsoft.com/) or [Visual Studio Code](https://code.visualstudio.com/).  
In that case, you need a MySQL 5.7 database server (running locally or in a Docker container).

## If you run the database server separately (not using *docker compose*)

- All MySQL settings and table schemas are described in [init-avg-db.sql](./mysql-setting/initdb.d/init-avg-db.sql).
- You can modify the DB connection information (db name, username...) as you like, but it needs to match [appsettings.json](./appsettings.json).
- The MySQL server only needs to accept connections from the C# web API server in this framework. Take care when handling the password.

## How to connect to the MySQL docker container
Open [docker-compose.yaml](./docker-compose.yaml) and uncomment the `ports` setting of `avg_db_server`. Then you can connect to the MySQL server using a MySQL client.

## Environment
- .NET 6.0 SDK
- MySQL 5.7

# AI development
You can use AI to create games with **avg.NET**, and we strongly recommend it.  
A game in **avg.NET** is made of plain text files: SQL, HTML and JavaScript. AI is good at reading and writing these.  
Writing the data by hand is tedious and error-prone. You need to keep IDs consistent across tables, assign flag bit values, use the control characters correctly, and write many INSERT rows.  
AI handles these details, so you can focus on the story and the atmosphere of your game.

1. Clone or download this repository.
1. Let AI learn about this framework by sharing the files.
1. Tell AI the story and mood of the game you want.
1. Let AI generate an original game.
1. Add your favorite background images, person images and audio files (or let AI generate them too).
1. Play it, then give AI feedback on what you notice (bugs, improvements...).

AI can also help you to
- learn about or improve **avg.NET**
- deploy your game
- translate text

And so on. So ask AI anything you want!

# Folders
## Controllers
C# sources for the ASP.NET Core web API.  
Usually, you don't need to modify them. But feel free to do so if needed.

## mysql-setting
There are two folders, *initdb.d* and *initdb.en.d*.  
There is a file named *init-avg-db.sql* in each folder.  
*init-avg-db.sql* is a script for creating the database and tables, and inserting data into the MySQL database.  
The file in the *initdb.d* folder is for Japanese, and the one in *initdb.en.d* is for English.

If you run the application with *docker compose*, the script is executed automatically in the MySQL container.  
But if you run the database server separately, you need to execute the script yourself.

## wwwroot
The root folder of the static files.  
*index.html* is the title page, served at http://localhost/.
### scenes
The folder for the HTML file of each scene.  
Each HTML file should have links to
- jQuery
- [avg.js](./wwwroot/avg.js)
- [avg.css](./wwwroot/avg.css)
- [bgm.js](./wwwroot/audio/bgm.js) (optional)
- the related scene image file in the [img](./wwwroot/img) folder
- the related audio file in the [audio](./wwwroot/audio) folder (optional)

Copying [00001.html](./wwwroot/scenes/00001.html) and modifying it is the easiest way to add a scene.

HTML files may also have links to related JavaScript files in the *scene-js* folder (as [00001.html](./wwwroot/scenes/00001.html) links to [yatsuka.js](./wwwroot/scene-js/yatsuka.js)).
### img
The folder for the image files of each scene.
### scene-js
The folder for JavaScript files used by scenes.  
Not every HTML file needs a specific JavaScript file.  
But if you need a special event in a scene that requires an additional JavaScript function,  
create a .js file in this folder, write the functions, then add a link to it in the HTML file of the scene.  
(This relates to the EVENT column of the MESSAGE table, so check the description below.)
### avg.js
The core JavaScript program of this framework.  
Usually, you don't need to modify it. But feel free to do so if needed.
### avg.css
The CSS file of this framework.  
Usually, you don't need to modify it. But feel free to do so if needed.

# Concepts
## Flag
Understanding the concept of the **flag** is important for using this framework.  
The flag is a value that represents the player's state.  
It is a 64-bit unsigned integer, used as a set of bits.

If you define the flag value 8 (1000 in binary) to represent whether the player has a specific item or not,  
the framework checks it by performing a bitwise AND between the item's flag value and the player's flag value.  
If the result is equal to the item's flag, then the player has the item.

Example:
- Player's flag is 42 (101010 in binary). 101010 AND 1000 = 1000, so the player has it.
- Player's flag is 34 (100010 in binary). 100010 AND 1000 = 0, so the player doesn't.

The initial value of the player's flag is 0.

During play, the player's flag value is kept in the browser's session storage (key: `AVG_FLAG_KEY`), not in the database.  
*avg.js* sends it to the server with each request, and stores the updated value returned by the server.  
So it is cleared when the browser tab is closed, unless the player saves the game (see 'Save/load' below).  
You can check or edit the current value in the browser's developer tools, which is useful for debugging.

## Tables
Understanding the concept of each table is also important for using this framework.  
The tables are defined in [init-avg-db.sql](mysql-setting/initdb.d/init-avg-db.sql) as CREATE TABLE statements.  
So, only a summary of each table is given below.

### SCENE
Each SCENE record pairs a scene ID with its path.  
The PATH column should have the relative path from *wwwroot* to its HTML file.  
This table also has a FLAG column, but it's not used now.

### COMMAND
A command is an action the player can take in a scene.

Records that have a specific SCENE_ID are things the player can do only at that scene.  
Records that have SCENE_ID = '00000' are common commands (e.g. use, check) the player can do at all scenes.  
So, at a scene, both the common commands and the scene-specific commands are shown to the player.

The COMMAND table also has a MODE column, which can have these values:
- 0: Normal Command
- 1: Person Command (the command can be used only in Person Mode)
- 2: Move Command (the command to go to other scenes)

### TARGET
A target is a thing the selected command can be applied to.  
When the player is in a room and selects the command 'check', the targets may be the things in the room (e.g. chair, table, bed ...).

There are also common targets. Those records have SCENE_ID = '00000', like common commands.  
For example, when the player has an item and selects the command 'use', the item can be a target at all scenes.

The FLAG column is the condition for whether the target is shown. It is checked by the bitwise operation described in the 'Flag' section.

When the player has the flag value 20 (10100 in binary), a TARGET record that has FLAG = 4 (100 in binary) is shown.  
But a record that has FLAG = 8 (1000 in binary) is not.

If the FLAG of the record is NULL, the target is always shown at the scene.

The DEST_SCENE_ID column is only for targets of commands that have MODE = 2 (move commands).  
It is the SCENE_ID the player goes to.

### MESSAGE
A message is a text shown to the player as the result of executing the command on the target, or a text that prompts the player to select a target for the command.

- FLAG, SET_FLAG, UNSET_FLAG columns

The FLAG column is the condition for whether the message is shown, the same as the FLAG column of the TARGET table described above.  
The SET_FLAG column holds the bits turned on in the player's flag when the message is shown.  
UNSET_FLAG is the opposite: the bits turned off in the player's flag when the message is shown.

- Player's flag value before and after a message is shown

|                     | decimal  | binary |
|:--------------------|---------:|-------:|
| player's flag value (before the message is shown) | 20       |  10100 |
| SET_FLAG value of the message         | 8        |  01000 |
| UNSET_FLAG value of the message        | 4        |  00100 |
| ---------------------- | -------- | ------ |
| player's flag value (after the message is shown)  | **24**       |  11000 |

- EVENT column

The EVENT column is the name of the JavaScript function that should be executed when the message is shown.  
If the EVENT column has the value 'getCommands' and the message is shown, *getCommands()* needs to be resolved as a JavaScript function.  
So, the function needs to be defined in *avg.js* or in a scene-specific .js file in the *scene-js* folder, as a property of the object *sceneEvents*.  
Some event functions are defined in *avg.js*, so they can be used as events by default.

One message can have multiple events. For example, if the EVENT column has the value 'func1,func2',
and the TEXT column has the value '^msg1^msg2',
the events and messages are processed in this order:
1. event 'func1' is executed
1. text 'msg1' is shown
1. event 'func2' is executed
1. text 'msg2' is shown

- TEXT column

The text content of the message.  

TEXT has the control characters shown below.

| control character           | meaning  |
|:-------------------:|:---------|
|^| The point where the associated event should be executed |
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
When the player clicks ▼,  
```
Hello avg!
```
is shown.  
Then, the associated event (defined in the EVENT column) is executed, because the TEXT value has a '^' character at the end.  

There are no escape sequences for these control characters, so you can't use them as part of the message content.  
But they are still useful for making messages easier to read.

## Initial message of the scene
The initial message of the scene is the message shown when the player enters the scene.  
It is the record of the MESSAGE table that has
- SCENE_ID: ID of the scene and
- COMMAND_ID: '000' and
- TARGET_ID: '000'

Typically, it is the message that tells the player where they are.  
(For example: '*You are at home.*', '*You are at the station.*')  
Initial messages have their own flag value, so you can change the initial message of the scene depending on the player's flag value.  

Usually, when the initial message of a scene is shown, the top-level commands need to be shown.  
So, **initial message records often have 'getCommands' as their event**.  

## Initial message of the command
The initial message of the command is the message shown when the player selects a command.  
It is the message that prompts the player to select a target for the command.  
For example: '*Check what?*', '*Go where?*'.  
It is the record of the MESSAGE table that has
- SCENE_ID: '00000' and
- COMMAND_ID: ID of the command the player selected and
- TARGET_ID: '000'

## Default message of the command
The default message of the command is the message shown when the command the player selected has no target.  
It is the message that tells the player the command has no target here (for example: '*There is nothing to check here.*').  
It is the record of the MESSAGE table that has
- SCENE_ID: '00000' and
- COMMAND_ID: ID of the command the player selected and
- TARGET_ID: '999'

## Person Mode
*Person mode* is also an important feature of this framework.  
If the player is with a person at a scene, the person's image should be shown over the background image of the scene.  
In this state, the player can select only *person commands* (e.g. show something to the person, talk about something with the person).  
That is *person mode*.

First, you have to prepare the person's image, which should have a transparent background.  
To set *person mode*, you have to add an *img* DOM element for the person's image.  
The element has to have the CSS class '*img-person1*', and has to be appended to the element that has the id '*image-area*'.  
(Currently only the *img-person1* class is in avg.css. But feel free to add *img-person2* if needed.)

Then, you need to execute the JavaScript function *setPersonMode(person_flag)*.  
Pass a value that identifies the person as the argument.

To unset *person mode*, remove the *img* element and execute the function *setPersonMode('')*.  
The argument is an empty string.

See *showPerson* and *hidePerson* in [yatsuka.js](./wwwroot/scene-js/yatsuka.js) for an example of setting and unsetting *person mode*.

## Save/load
The events 'showSaveDialog' and 'showLoadDialog' are defined in *avg.js*.  
When they are executed as a message event, the save/load dialog box is shown.  
Then the player can save the current flag value and scene, or load them.

Player data is saved in the browser's local storage.

# data-sheet.xlsx
data-sheet.xlsx will help you write INSERT statements for each table.
