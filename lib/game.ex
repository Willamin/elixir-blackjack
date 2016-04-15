require Util
require Cards
defmodule Game do

  def play() do
    new_shoe |> play
  end

  def split_score(string) do
    if Regex.match?(~r/[0-9]+\n[0-9]+/, string) do
      split = string |> String.split("\n") 
      split |> Enum.map(fn(x) -> {i, b} = x |> Integer.parse(); i end)
    else
      [0,0]
    end
  end

  def play(shoe) do
    {return_code, shoe} = shoe |> play_hand
    current = [0, 0]
    case File.read("score") do
      {:ok, body} -> current = body |> split_score
      _ -> current = [0,0]
    end
    {:ok, file} = File.open "score", [:write]

    [losses|[wins|_]] = current
    cond do
      return_code == :win -> IO.puts "Hooray, you won!"; wins = wins + 1
      return_code == :loss -> IO.puts "Sorry, you lost."; losses = losses + 1
      return_code == :empty_deck -> IO.puts "Ran out of cards (we'll throw out this game)"; shoe = new_shoe
      true -> IO.puts "huh?"
    end
    IO.binwrite file, "#{losses}\n#{wins}"
    File.close file
    IO.puts "You've won #{wins} out of #{wins + losses}"
    case play_again_prompt do
      :play -> Util.reprint; play(shoe)
      _ -> IO.puts "bye"
    end
  end

  def play_again_prompt() do
    IO.puts "Let's play again!"
    input = IO.gets "? "
    cond do
      ~r/.*(yes|play|go).*/  |> Regex.match?(input) -> :play
      ~r/.*(no|exit|leave|bye|quit).*/ |> Regex.match?(input) -> :exit
      true -> :play
    end
  end

  def new_shoe() do
    (1 |> Cards.shuffled_decks)
  end

  def play_hand(shoe) do

    player_cards = []
    dealer_cards = []
    try do
    # Initial deal
      {:ok, player_cards, shoe} = deal player_cards, shoe, 2
      {:ok, dealer_cards, shoe} = deal dealer_cards, shoe, 2
      print_game(player_cards,dealer_cards)
      
      # Ask player for hits
      {:ok, player_cards, dealer_cards, shoe} = hit_prompt player_cards, dealer_cards, shoe
      print_game player_cards, dealer_cards
      # Dealer hits
      {:ok, dealer_cards, shoe} = hit_dealer dealer_cards, shoe
      # Print final score
      Util.reprint
      dc_count = length(dealer_cards) - 2
      if dc_count == 1 do
        s = ""
      else
        s = "s"
      end
      IO.puts "The Dealer hits #{dc_count} time#{s}"
      print_game(player_cards, dealer_cards)
      player_score = Cards.count_score(player_cards)
      dealer_score = Cards.count_score(dealer_cards)

      if player_score > 21 do bust_message player_score end
      IO.puts ""
      IO.puts "Player Score:" <> IO.ANSI.green <> to_string(player_score) <> IO.ANSI.default_color
      IO.puts "Dealer Score:" <> IO.ANSI.green <> to_string(dealer_score) <> IO.ANSI.default_color
      IO.puts ""

      cond do
        player_score > 21 ->
          {:loss, shoe}
        dealer_score > 21 ->
          {:win, shoe}
        player_score > dealer_score ->
          {:win, shoe}
        true ->
          {:loss, shoe}
      end
    rescue
      _ in MatchError -> {:empty_deck, shoe} 
    end
  end

  ## move 1 card from shoe to hand
  ## returning {:ok, hand, shoe} if the shoe isn't empty before the deal
  ## returning {:empty_deck, hand, shoe} if the shoe is empty before the deal
  def real_deal(hand, shoe) do
    if shoe |> length > 0 do
      [dealing_card|shoe] = shoe
      hand = hand ++ [dealing_card]
      {:ok, hand, shoe}
    else
      {:empty_deck, hand, shoe}
    end
  end

  ## move 1 or less cards from shoe to hand
  ## recursive base case
  def deal(hand, shoe, count) when count <= 1 do
    if shoe |> length > 0 do
      {:ok, hand, shoe} = real_deal(hand,shoe)
      {:ok, hand, shoe}
    else
      {:empty_deck, hand, shoe}
    end
  end

  ## move more than 1 card from shoe to hand
  ## recursive call
  def deal(hand, shoe, count) do
    {_result, hand, shoe} = real_deal(hand,shoe)
    {_result, hand, shoe} = deal(hand, shoe, count - 1)
    {:ok, hand, shoe}
  end

  def print_hand(hand, prompt, who) when length(hand) > 0 do
    IO.write IO.ANSI.yellow
    IO.puts prompt
    IO.write IO.ANSI.default_color
    if who == :dealer do
      c = hd(hand)
      c = %{c | rank: 0}
      hand = [c|tl(hand)]
    end
    for card <- hand do
      IO.puts "    " <> Cards.card_to_string(card)
    end
  end

  def print_game(player_hand, dealer_hand) do
    player_hand |> print_hand("You've been dealt ", :player)
    dealer_hand |> print_hand("The dealer has ", :dealer)
  end

  def hand_prompt() do
    IO.puts "You have the choice to:"
    IO.puts "Take a hit or stay with what you have?"
  end

  def hand_get() do
    input = IO.gets "? "
    return = cond do
      ~r/.*(hit|take|h).*/  |> Regex.match?(input) -> :hit
      ~r/.*(stay|keep|s).*/ |> Regex.match?(input) -> :stay
      true -> hand_get
    end
    Util.reprint
    return
  end

  def bust_message(score) do
    IO.puts "You busted by having #{score} points"
  end

  def hit_prompt(player_cards,dealer_cards,shoe) do
    hand_prompt
    score = player_cards |> Cards.count_score
    if score > 21 do
      {:ok, player_cards, dealer_cards, shoe}
    else
      case hand_get do
        :hit ->
          {:ok, player_cards, shoe} = deal player_cards, shoe, 1
          print_game player_cards, dealer_cards
          hit_prompt player_cards, dealer_cards, shoe
        :stay -> {:ok, player_cards, dealer_cards, shoe}
      end
    end
  end

  def hit_dealer(dealer_cards,shoe) do
    score = dealer_cards |> Cards.count_score
    if score < 17 do
      {:ok, dealer_cards, shoe} = deal dealer_cards, shoe, 1
      hit_dealer dealer_cards, shoe
    else
      {:ok, dealer_cards, shoe}
    end
  end

end