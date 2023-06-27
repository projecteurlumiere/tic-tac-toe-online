def make_a_move(player_id, cell_number)
  access_player_hash(player_id)[:current_player_class].play(cell_number)
end