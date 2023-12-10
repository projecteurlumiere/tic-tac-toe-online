before "/" do
  return if request.websocket?

  params[:board] = params[:board].to_i
  @server_address = $settings_hash[:server_address]
end

get "/" do
  puts "#received params are #{params} and board is #{params[:board]}"

  case params[:board]
  when 3 || 5
    board_show
  else
    board_index
  end
end

def board_index
  @template = :entrance

  erb :not_layout
end

def board_show
  puts "PARAMETER PROCS"
  @size = params[:board]

  erb :board
end