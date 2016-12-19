## Plugins

Here's a list of all the things you can do with twubot:

### Stream currency
Viewers earn credits at a configurable rate. The default is 15 credits every 15 minutes.

### Bankhack
To earn more credits, viewers can participate in bankhack. Also at a rate of every 15 minutes.

### Command learning
As you find people asking the same questions on stream, you (or your mods) can add useful help commands with !learn

Example:
`
viewer: What platform is this?
streamer: !learn platform everything we play is Xbox One, the best platform.
viewer2: !platform
twubot: everything we play is Xbox One, the best platform.
viewer3: psh, ps4 pro for life.
`

These commands are unlimited. But it could slow performance to add hundreds. Stress testing still needs to be performed.

### Event counter
When things happen on stream, viewers can add to a counter.

Example:
`
viewer: !count rip
twubot: rip now at 100
`

### Giveaways
Everyone likes giving stuff away! This plugin allows the streamer or moderator to start a giveaway, viewers enter and then a winner is drawn.

There are no limits on the number of viewers who can enter. The price of entry is configurable (defaults to 100 credits) and the maximum number of entries per viewer is configurable (default 10).

Example:
`
moderator: !giveaway one pony
twubot: The giveaway has launched! Cough up 100 credits for a chance to win! Use !win to enter the drawing.
viewer: !win
twubot: viewer you are in for the giveaway. Your remaining balance is 500 and you can attempt an additional 9 times.
streamer: !closegiveaway
twubot: The giveaway is closed! We will now tally the entries
twubot: And the winner is........
twubot: viewer! Please whisper one of the moderators to claim your prize!
`

### Custom Greetings
Users can pay credits (default 20000) to get a custom greeting that is displayed every time they enter chat.

### Inventory/Shop
Our first community sourced feature! Moderators can add items to a stream shop for viewers to purchase with stream credits. This is useful if you have a battle system and want to leverage credits for reviving a team.

Commands:
`
!addinventory thing #cost
!addinventory thing #cost #stock (stock defaults to 20)
!addstock thing
!addstock thing #stock (stock defaults to 20)
!purchase thing
!purchase thing #amount (amount purchased defaults to 1)
!store
!inventory
!sell thing #amount (amount to sell defaults to 1)
!discard thing #amount (amount to discard defaults to 1)
`

### Quote
Moderators can add quotes as heard on stream. This is locked down to moderators to avoid malicious things put into the bot.

Example:
`
moderator: !quote add something that was just said on stream
viewer !quote random
twubot: "something that was just said on stream"
`

### Ranks
Users can purchase custom ranks that cost a certain amount of credits. These ranks can then be joined by other users for credits

Commands:
`
!addrank 2000000 high rollers
!joinrank high rollers
!leaverank high rollers
!listranks
!checkranks
`

### Reminders
Moderators can set messages that are put in chat on an interval (default is 10 minutes)

The number of messages set is unlimited and the bot will choose a random one to display every 10 minutes.

Example:
`
moderator: !addreminder remember to follow the stream on twitter
.
. 10 minutes later
.
twubot: remember to follow the stream on twitter
`

### Battle Royale System
Our second community feature! Moderators can create a battle group. The streamer is the champion and anyone can join in the battle against them.

The total number of people required to start a battle is configurable (default 1)

Commands:
`
!openroyale
!joinroyale
!startroyale #challengers
!nextchallengers #challengers
!leaveroyale
!kickroyale user
!mixroyale
!checkroyale
!closeroyale
`

### Viewership tracking
Track when a user started following the channel and if they are currently present or when they were last seen

Commands:
`
!lastseen user
!checktime user
!follow user
`

### Voting
Who doesn't like Democracy? If you're uncertain what to do, put it to your stream!

Voting takes 2 minutes by default but can be set to any number of minutes.

Example:
`
moderator: !vote what should we do tonight pinky? answers: same thing we do every night, try to take over the world
viewer1: !answer same thing we do every night
viewer2: !answer same thing we do every night
viewer3: !answer try to take over the world
.
. 2 minutes later
.
It's all over! The winner is same thing we do every night!
`
