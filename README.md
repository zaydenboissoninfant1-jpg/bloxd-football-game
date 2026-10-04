# BLOXD.IO Football Game

A Bloxd.io-style football game prototype with team selection, custom kits, goal logic, roster tracking, and special owner tags.

## Included features
- 10 football teams: PSG, Barcelona, Real Madrid, Al Nassr, Al Hilala, Manchester City, Bayern Munich, Liverpool, Juventus, and Inter Milan
- New players start as Free Agent
- Team selection menu and roster viewer
- Team names displayed above player heads
- Team-specific football kits and armor styling
- Special owner user: BLOXD_IO_YT_ZAY
- Head number 1 for the owner
- Ball, goals, and match score logic

## Files
- `src/ReplicatedStorage/FootballConfig.lua` — team data and owner info
- `src/ServerScriptService/FootballGame.server.lua` — team assignment and player sync
- `src/ServerScriptService/BallPhysics.server.lua` — football ball behavior
- `src/ServerScriptService/MatchManager.server.lua` — scores, goals, and match flow
- `src/StarterPlayer/StarterPlayerScripts/FootballClient.client.lua` — team menu and UI

## Controls
- Press `T` to open the Team Menu
- Use WASD to move
- Click to shoot or kick the ball
- Remain a Free Agent if you do not want to join a club

## Owner tag
- Username: `BLOXD_IO_YT_ZAY`
- Chat tag: `BLOXD_IO_YT_ZAY`
- Head number: `1`

This is a Bloxd.io-inspired football gameplay prototype designed to fit the style and structure of a team-based soccer game.
