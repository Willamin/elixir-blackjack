defmodule Cards do
	def deck() do
    for rank_value <- 1..13 do
      for suit_value <- [:spades, :hearts, :clubs, :diamonds] do
        %{rank: rank_value, suit: suit_value}
      end
    end |> List.flatten
  end

  def shuffled_decks(count) when count == 1 do
    deck |> Enum.shuffle
  end

  def shuffled_decks(count) when count > 1 do
    shuffled_decks(count - 1) |> Enum.shuffle
  end

  def card_to_string(card) do
    IO.ANSI.default_color <>
    if card.rank == 0 do
      "[an unrevealed card]"
    else
      case card.rank do
        1  -> "ace"
        11 -> "jack"
        12 -> "queen"
        13 -> "king"
        _  -> card.rank |> to_string
      end 
      <> " of " <>
      case card.suit do
        :spades   -> IO.ANSI.blue <> "spades"
        :hearts   -> IO.ANSI.red  <> "hearts"
        :clubs    -> IO.ANSI.blue <> "clubs"
        :diamonds -> IO.ANSI.red  <> "diamonds"
      end
    end
    <> IO.ANSI.default_color
  end

  def count_score(hand) do
    score = hand |> Enum.map(fn(card) ->
      case card.rank do
        1  -> 0
        11 -> 10
        12 -> 10
        13 -> 10
        _  -> card.rank
      end
    end) |> Enum.sum
    aces_count = hand |> Enum.map(fn(card) ->
      case card.rank do
        1 -> 1
        _ -> 0
      end
    end) |> Enum.sum
    if aces_count > 0 do
      score = try_aces score, aces_count, 0
    end
    score
  end

  def try_aces(score, aces, attempt) do
    ace_attempt = attempt * 1 + (aces - attempt) * 11
    if score + ace_attempt <= 21 do
      score + ace_attempt
    else
      if aces > attempt do
        try_aces(score, aces, attempt + 1)
      else
        score + ace_attempt
      end
    end
  end
end