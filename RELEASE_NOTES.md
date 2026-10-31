# Release Notes

## 3.1
- click the command area outside the targets to cancel the command
- a line between the targets in the scene and the common targets (e.g. items the player has)
- no text selection when clicking the game screen quickly

Game data (SQL, HTML and JavaScript files) and save data of 3.0 can be used in 3.1 as they are.  
The target API (`/api/target`) returns a new property `common` for each target.

## 3.0
- .NET 10, MySQL 8.4 and jQuery 4.0
- game screen scaled to fit the window, and centered
- click the message area to skip typing or go to the next part
- text speed setting
- cancel target for commands (only by adding records)
- API tests
- bug fixes (e.g. flag values above 2^53, a flag value of 0 not saved)

Game data (SQL, HTML and JavaScript files) and save data of 2.x can be used in 3.0 as they are.  
But the database volume of MySQL 5.7 can't be used by MySQL 8.4, so run `docker compose down -v` once (see [Environment](./README.md#environment) in README).

## 2.7
- title page (*wwwroot/index.html*) shown at `/`
- updated sample game

## 2.6
- background music
- scroll in command area

## 2.5
- save/load
- multiple events in one message

## 2.0
- changed table schema

Versions 2.0 and later are not compatible with 1.0.
