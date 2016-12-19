## Deployment
The options listed here are in order of convenience.

### Let us do it!
Like any good problem, why should you have to worry about running, upgrading, maintaining and dealing with something you didn't create?

Check out our [plans](PLANS.md) to learn more!

### Want to Do it Yourself?
We understand. Save a bit of money and learn something along the way.

#### You'll Need MongoDB
If you want to run any of the following options, you need MongoDB.

You can either [install your own](https://docs.mongodb.com/manual/installation/#tutorials) from MongoDB proper or use one of the many options available out there to have MongoDB run for you.

__Options__:
* [MLab](https://mlab.com)
* [Compose](https://www.compose.com/)
* [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/pricing)

### Heroku

    % heroku create --stack cedar
    % git push heroku master

If your Heroku account has been verified you can run the following to enable
and add the Redis to Go addon to your app.

    % heroku addons:add mongolab:nano

If you run into any problems, checkout Heroku's [docs][heroku-node-docs].

You'll need to edit the `Procfile` to set the name of your hubot.

Additional documentation can be found on the
[deploying hubot onto Heroku][deploy-heroku] wiki page.

#### Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart`
if you're having issues.

### Running twubot Locally

These instructions assume you've followed [the configuration instructions](CONFIGURATION.md)

You can start twubot locally by running:

    % source source.sh
    % bin/hubot

You'll see some start up output about where your scripts come from and a
prompt:

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    twubot>

From here you can start typing commands as you would in chat

    twubot> !bankhack 100
    twubot> Sorry, the heat is too hot. Stay out of the kitchen!
    ...

