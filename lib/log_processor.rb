# encoding: UTF-8

require 'json'

class LogProcessor
  def initialize(pid)
    @pid = pid
  end

  def process_line(line)
    line = line.force_encoding('ISO-8859-1').
      gsub(/\e\[\d+m/, ''). # strip color sequences out
      gsub(/[\d-]+ [\d:]+ \[[A-Z]+\]\s/, ''). # strip time prefix
      strip

    process_normal_line(line)
  end

  def process_normal_line(line)
    line = line.force_encoding('ISO-8859-1').
              gsub(/\u001b\[(m|\d+;\dm)?/, ''). # strip color sequences out
              gsub(/(>)?\r/, '').
              gsub(/[\d:]+\s\[[A-Z]+\]\s/, '').strip  # strip message prefix

    case line
    when /^<(\w+)> (.*)$/
      event 'chat', nick: $1, msg: $2

    when /Done \(/
      event 'started'

    when /^Stopping server$/
      event 'stopping'

    when /^(\w+).*logged in with entity id/
      event 'player_connected', auth: 'mojang', uid: $1

    when /^(\w+) lost connection: (.*)$/
      event 'player_disconnected', auth: 'mojang', uid: $1, reason: $2

    when /^Connected players:(.*)$/
      @players = $1.split(',').map(&:strip)
      event 'players_list', auth: 'mojang', uids: @players

    when /^(\w+): Added (\w+) to white-list/
      settings_changed $1, add: 'whitelist', value: $2
    when /^(\w+): Removed (\w+) from white-list/
      settings_changed $1, remove: 'whitelist', value: $2
    when /^(\w+): Opping (\w+)/
      settings_changed $1, add: 'ops', value: $2
    when /^(\w+): De-opping (\w+)/
      settings_changed $1, remove: 'ops', value: $2
    when /^(\w+): Banning (\w+)/
      settings_changed $1, add: 'blacklist', value: $2
    when /^(\w+): Pardoning (\w+)/
      settings_changed $1, remove: 'blacklist', value: $2

    when /FAILED TO BIND TO PORT!/
      event 'fatal_error'
      Process.kill :TERM, @pid

    when 'Player found..', 'Repair is active..'
      # ignore these SPAM

    else
      event 'info', msg: line.strip
    end

    def settings_changed(actor, transform)
      event 'settings_changed', transform.merge(actor: actor)
    end
  end

  def event(event, options = {})
    payload = {
      ts: Time.now.utc.iso8601,
      event: event
    }.merge(options)

    STDOUT.puts(payload.to_json)
  end

# private

  # Extracts [key, value] pairs of settings for their console messages
  def parse_settings(msg)
    case msg
    when /Added (\w+) to the whitelist/
      { add: 'whitelist', value: $1 }

    when /Removed (\w+) from the whitelist/
      { remove: 'whitelist', value: $1 }

    when /Banned player (\w+)/
      { add: 'blacklist', value: $1 }

    when /Unbanned player (\w+)/
      { remove: 'whitelist', value: $1 }

    when /Opped (\w+)/
      { add: 'ops', value: $1 }

    when /De-opped (\w+)/
      { remove: 'ops', value: $1 }

    when /default game mode is now (\w+)/
      { set: 'gamemode', value: GAME_MODES.index($1) }

    when /Set game difficulty to (\w+)/
      { set: 'difficulty', value: DIFFICULTIES.index($1) }
    end
  end
end
