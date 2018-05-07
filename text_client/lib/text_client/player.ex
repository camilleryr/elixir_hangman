defmodule TextClient.Player do
  alias TextClient.{State, Summary, Prompter, Mover}

  def play(%State{tally: %{game_state: :won}}) do
    exit_with_message("You Won")
  end

  def play(%State{tally: %{game_state: :lost}}) do
    exit_with_message("You Lost")
  end

  def play(game = %State{tally: %{game_state: :good_guess}}) do
    continue_with_message(game, "Good Guess")
  end

  def play(game = %State{tally: %{game_state: :bad_guess}}) do
    continue_with_message(game, "Bad Guess")
  end

  def play(game = %State{tally: %{game_state: :already_used}}) do
    continue_with_message(game, "You have already guessed that letter")
  end

  def play(game) do
    continue(game)
  end

  defp continue(game) do
    game
    |> Summary.display()
    |> Prompter.accept_move()
    |> Mover.make_move()
    |> play()
  end

  def make_move(game) do
    game
  end

  defp continue_with_message(game, msg) do
    IO.puts(msg)
    continue(game)
  end

  defp exit_with_message(msg) do
    IO.puts(msg)
    exit(:normal)
  end
end
