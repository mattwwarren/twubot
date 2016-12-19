## Configuration
Configuration for twubot is done on via command-line environment variables. The suggested way to manage these is to have a source.sh file, which looks like the provided example-source.sh file.

### Required
The following must be set in order for twubot to operate

MONGODB_URL -- The MongoDB URL to connect to your MongoDB instance
HUBOT_TWITCH_CHANNELS -- This should be your channel name
HUBOT_TWITCH_ADMINS -- A comma delimited list of moderators
HUBOT_TWITCH_OWNERS -- Your twitch user name
HUBOT_TWITCH_CLIENT_ID -- The API client ID generated from [Twitch](https://www.twitch.tv/kraken/oauth2/clients/new)
HUBOT_TWITCH_CLIENT_SECRET -- The API client secret generated above. For more information on what this is and how to create it, please read [Twitch API](TWITCH_API_CONNECTION)
HUBOT_TWITCH_REDIRECT_URI -- Set this to http://localhost

### Optional
These all have somewhat sane defaults. You may change them if you wish to have different behavior. At this time, there is no way to change them without restarting twubot.

HUBOT_BANKHACK_TIMEOUT -- This is an integer to represent how many minutes between bankhack opportunities (Default: 15)
HUBOT_BANKHACK_WAGER_TIME -- An integer representing how long users have to wager in bankhack (Default: 2)
HUBOT_BANKHACK_WIN -- Percentage change to win a bankhack (Default: 50)
HUBOT_BANKHACK_MULTIPLIER -- The multiplier for bankhack winnings (Default: 2)
HUBOT_CREDITS_PER_X -- Number of credits to give out per interval (Default: 15)
HUBOT_CREDITS_TIMEOUT -- Interval on which to give credits (Default: 15)
HUBOT_GIVEAWAY_COST -- Cost to enter a giveaway (Default: 100)
HUBOT_GIVEAWAY_CHANCES -- Total number of entries allowed for a giveaway (Default: 10)
HUBOT_CUSTOM_GREETING_PRICE -- Price to purchase a custom greeting (Default: 20000)
HUBOT_INVENTORY_SELL_DIVISOR -- The divisor used when making a sale back to the store (Default: 2)
HUBOT_INVENTORY_DEFAULT_STOCK -- Default stock if one is not specified when adding a new item or new stock (Default: 20)
HUBOT_INVENTORY_COUNT_DEFAULT_MAX -- Maximum allowed of a single item in a user's inventory (Default: 5)
HUBOT_INVENTORY_DEFAULT_MAX -- Maximum total items allowed in inventory (Default: 10)
HUBOT_TWITCH_RANK_PRICE -- Price to purchase a rank, if not otherwise specified (Default: 20000)
HUBOT_REMINDER_INTERVAL -- Minutes between random reminder message (Default: 10)
HUBOT_ROYALE_SIZE -- Size of challengers and champions in a battle (Default: 4)
HUBOT_DEFAULT_CHALLENGER_COUNT -- Number of challengers to move out of battle(Default: 1)
HUBOT_VOTE_TIME -- Minutes to run a vote (Default: 2)
HUBOT_MAX_COMMAND_LIST -- Maximum number of commands to list in !commandlist response. Used to avoid huge messages (Default: 20)
