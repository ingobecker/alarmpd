# alarmpd

Alarmpd is a small daemon that takes control over a MPD in order to wake you up. It is capable of handling as many alarms as you want. Scheduling an alarm works directly out of your favourite MPD-client by creating a playlist.

## Features

* schedule alarms using your favourite mpd-client
* every alarm has it's own playlist
* scheduling alarms is as easy as creating playlists
* wakes you up gently by fading in
* gentle snooze function by simply turning down the volume while being in fade mode
* create as much alarms as you want
* alarmpd can run on another machine than the one running the controlled mpd

## Installation

```
gem install alarmpd
```

## Usage

Starting the daemon from the commandline:
```
$ alarmpd -h hostname
```
To start the daemon in the background just add the `-b` flag.

Starting using a config file:
```
$ alarmpd -c config.yml
```

## Scheduling alarms

Scheduling new alarms is as easy as creating a playlist. The name of the playlist determines the wake up time. A playlist named `Monday 7:30` will play it's content every monday at 7:30. Playlists that do not follow the scheme `<Dayname> <hh:mm>` will be ignored. To deactivate an alarm rename it into something like `!Monday 7:30`. This way you could keep your monday morning playlist and reschedule it by just removing the exclamation mark.

## Fading alarms / snooze

By supplying the commandline option `-f ` or setting the `fade_interval` in the config file, alarms will be faded in from zero to maximum volume. Supply an integer value to determine the interval between every incrementation of the volume in seconds. This behaviour will stop automatically once the maximum volume is reached. By turning down the volume before it has reached it's maximum you will get a gentle snooze function as alarmpd only stops fading once it reached the maximum volume. To stop the process before alarmpd reached a deafening level simply pause the playback, set the volume to 100% and wait for at least the amount of seconds you supplied as `fade_interval`.

## Configuration

You can make your configuration persistent by using a config file written in yaml. Options given on the commandline always have precedence over the those specified in the configuration file.

```yaml
host: 'pi'
port: 6600
background: true
interval: 5
```
