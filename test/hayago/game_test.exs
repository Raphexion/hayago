defmodule Hayago.GameTest do
  alias Hayago.{Game, State}
  use ExUnit.Case
  doctest Hayago.Game

  describe "state/1" do
    test "returns the game's current state" do
      state = %State{current: :white}
      assert Game.state(%Game{history: [state, %State{}]}) == state
    end

    test "returns a game's previous state" do
      state = %State{current: :white}
      assert Game.state(%Game{history: [%State{}, state], index: 1}) == state
    end
  end

  test "place/1 adds a state to the history to place a stone on the board" do
    assert Game.place(
             %Game{history: [%State{positions: [nil, nil, nil, nil], current: :black}]},
             0
           ) ==
             %Game{
               history: [
                 %State{positions: [:black, nil, nil, nil], current: :white},
                 %State{positions: [nil, nil, nil, nil], current: :black}
               ]
             }
  end

  test "jump/1 updates the game's index attribute" do
    assert %Game{index: 1} = Game.jump(%Game{history: [%State{}, %State{}]}, 1)
  end

  describe "history?/2" do
    test "returns true for an existing index" do
      assert Game.history?(%Game{}, 0)
      assert Game.history?(%Game{history: [%State{}, %State{}]}, 1)
    end

    test "returns false for a negative index" do
      refute Game.history?(%Game{}, -1)
    end

    test "returns false for an index that exceeds the history list indexes" do
      refute Game.history?(%Game{}, -1)
    end
  end
end
