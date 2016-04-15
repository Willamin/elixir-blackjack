require Util
defmodule Blackjack do

  def menu_get() do
    input = IO.gets "? "
    cond do
      ~r/.*(play|game|go).*/         |> Regex.match?(input) -> :game
      ~r/.*(about|help|info|\?).*/   |> Regex.match?(input) -> :info
      ~r/.*(leave|exit|quit|bye).*/  |> Regex.match?(input) -> :exit
      ~r/.*(reset|clear).*/          |> Regex.match?(input) -> :reset
      ~r/.*(view|score).*/           |> Regex.match?(input) -> :view
      true -> menu_get
    end
  end

  def menu_show() do
    Util.reprint
    IO.puts "What would you like to do?"
    IO.puts "Play a game, get info, view or reset your scores, or leave?"
    menu_get
  end

  def go() do
    menu_show |> check
  end

  def check(result) do
    case result do
      :game -> Util.reprint; Game.play; go
      :info -> info
      :exit -> IO.puts "Play again soon!"
      :reset -> reset_score
      :view -> view_score
    end
  end

  def info() do
    Util.reprint
    IO.puts "by Will Lewis"
    IO.puts "CFC547"
    IO.puts "for CPSC 4100"
    IO.gets "Press enter to continue..."
    go
  end

  def reset_score() do
    Util.reprint
    {:ok, file} = File.open "score", [:write]
    IO.binwrite file, "0\n0"
    File.close file
    IO.puts "Scores reset"
    IO.gets "Press enter to continue..."
    go
  end

  def view_score() do
    Util.reprint
    case File.read("score") do
      {:ok, body} -> current = body |> Game.split_score
      _ -> current = [0,0]
    end
    [losses|[wins|_]] = current
    IO.puts "Current score: "
    IO.puts "You've won " <> IO.ANSI.green <> to_string(wins) <> IO.ANSI.default_color <> " out of " <> IO.ANSI.yellow <> to_string(wins + losses) <> IO.ANSI.default_color <> " total games."
    IO.gets "Press enter to continue..."
    go
  end

end

# Start the game
#Blackjack.go
# End by putting a newline
#IO.puts ""