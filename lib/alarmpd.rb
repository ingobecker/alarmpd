require 'rufus-scheduler'
require 'ruby-mpd'

Alarm = Struct.new(:name, :time)

class AlarMPD

  H_SECS = 60 * 60
  D_SECS = H_SECS * 24

  TIME_REGEXP = '([0-9]|0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])'
  DAY_REGEXP = "(#{Date::DAYNAMES.join('|')})"

  attr_reader :mpd, :latest_alarm
  attr_accessor :interval, :fade_in

  def initialize(host, port)
    @mpd = MPD.new host, port
    @scheduler = Rufus::Scheduler.new
    if defined?(RSpec)
      @scheduler.pause 
    else
      @mpd.connect
    end
    @fade_interval = 10
    @interval = 20
    @latest_alarm = nil
    @fade_in = false
    @alarm_job = nil
  end

  def connect
    @mpd.connect
  end

  def stop
    @running = false
  end

  def fade_interval=(interval)
    @fade_interval = interval
    @fade_in = interval != 0
  end

  def fade_in?
    @fade_in
  end

  def alarm_job
    p = @mpd.playlists.find {|p| p.name == @latest_alarm.name}
    offset = @mpd.queue.count
    p.load

    if fade_in?
      @mpd.volume = 0
      @scheduler.every(@fade_interval, method(:fade_in_job))
    end

    @mpd.play offset
  end

  def fade_in_job(job)
    @mpd.volume = @mpd.volume + 1
    job.unschedule if @mpd.volume == 100
  end

  def refresh
    new_alarm = next_alarm
    if new_alarm && (@latest_alarm.nil? || new_alarm.time != @latest_alarm.time)
      @latest_alarm = new_alarm
      @alarm_job.unschedule if @alarm_job
      @alarm_job = @scheduler.schedule_at(new_alarm.time, method(:alarm_job))
    end
  end

  def next_alarm
    alarms = []
    @mpd.playlists.each do |playlist|
      time = AlarMPD.parse_entry(playlist.name)
      alarms << Alarm.new(playlist.name, time) if time
    end
    alarms = alarms.sort_by &:time if alarms.any?
    alarms.first
  end

  def self.parse_entry(playlist_entry)
    match = playlist_entry.match "^#{DAY_REGEXP} #{TIME_REGEXP}$"
    if match
      time = AlarMPD.prepare_time(match[1], match[2].to_i, match[3].to_i)
    end
  end

  def self.prepare_time(day, hour, minute)

    wday = Date::DAYNAMES.index(day)
    current_wday = Time.now.wday

    offset = if wday < current_wday
               7 - (current_wday - wday)
             else
               wday - current_wday
             end

    offset_secs = offset * D_SECS + H_SECS * hour + minute * 60
    d = Date.today.to_time + offset_secs
    d = d + D_SECS * 7 if d < Time.now
    d
  end

  def run
    @running = true
    while @running do
      refresh
      sleep @interval
    end
    @alarm_job.unschedule if @alarm_job
  end
end
