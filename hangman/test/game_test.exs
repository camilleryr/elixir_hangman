defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert Enum.all?(game.letters, fn x -> x == String.downcase(x, :ascii) end)
  end

  test "state isnt' changed for :won or lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert {^game, _tally} = Game.make_move(game, "x")
    end
  end

  test "first occurance of letter is not already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurance of letter is not already used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    assert MapSet.member?(game.used, "x")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "the complete word is guessed" do
    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"b", :already_used},
      {"l", :good_guess},
      {"e", :won}
    ]

    game = Game.new_game("wibble")

    fun = fn {guess, state}, game ->
      {game, _tally} = Game.make_move(game, guess)
      assert game.game_state == state
      game
    end

    Enum.reduce(moves, game, fun)
  end

  test "bad guess is recognized" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "game is lost after 7 turns" do
    game = Game.new_game("wibble")
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
    {game, _tally} = Game.make_move(game, "c")
    assert game.game_state == :bad_guess
    assert game.turns_left == 5
    {game, _tally} = Game.make_move(game, "d")
    assert game.game_state == :bad_guess
    assert game.turns_left == 4
    {game, _tally} = Game.make_move(game, "f")
    assert game.game_state == :bad_guess
    assert game.turns_left == 3
    {game, _tally} = Game.make_move(game, "h")
    assert game.game_state == :bad_guess
    assert game.turns_left == 2
    {game, _tally} = Game.make_move(game, "j")
    assert game.game_state == :bad_guess
    assert game.turns_left == 1
    {game, _tally} = Game.make_move(game, "k")
    assert game.game_state == :lost
  end
end
