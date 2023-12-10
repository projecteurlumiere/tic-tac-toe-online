Bundler.require

require_relative 'tictactoe'
require_relative 'matchmaker'
require_all 'controllers'
require_all 'helpers'

$settings_hash = YAML.load(File.read("settings.yaml"))

$matchmaker = Matchmaker.new

set :server, 'thin'
set :static_cache_control, [:no_cache]
set :bind, $settings_hash[:ip_bind]
set :port, $settings_hash[:port] || 4567

configure do
  enable :sessions
end

before do
  cache_control :no_cache
end

get '/' do
end

# // To server:
# // msg: -1, 0 or 1-25; integer -1 if leave game, 0 if ready, 1-25 if make a choice

# // emoji: emoji string to show TO DO

# // From server:
# // found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
# // board: Array;
# // turn: string x or o;
# // symbol: X or O; string (this is your symbol)
# // gameover: false or true when it's over
# // error: boolean;
# // win: boolean; (if none then undef)
# // leaver: true (otherwise undefined)