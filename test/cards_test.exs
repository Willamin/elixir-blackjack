defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  def ace() do
    %{rank: 1}
  end

  # one ace
  test "only ace" do
    assert [ace]              |> Cards.count_score == 11
  end

  test "ace and 20" do
    assert [ace, %{rank: 20}] |> Cards.count_score == 21
  end

  test "ace and 10" do
    assert [ace, %{rank: 10}] |> Cards.count_score == 21
  end

  # two aces
  test "2 aces" do
    assert [ace, ace]              |> Cards.count_score == 12
  end

  test "2 aces and 19" do
    assert [ace, ace, %{rank: 19}] |> Cards.count_score == 21
  end

  test "2 aces and 9" do
    assert [ace, ace, %{rank: 9}]  |> Cards.count_score == 21
  end

  # three aces
  test "3 aces" do
    assert [ace, ace, ace]              |> Cards.count_score == 13
  end

  test "3 aces and 18" do
    assert [ace, ace, ace, %{rank: 18}] |> Cards.count_score == 21
  end

  test "3 aces and 8" do
    assert [ace, ace, ace, %{rank: 8}] |> Cards.count_score == 21
  end
end
