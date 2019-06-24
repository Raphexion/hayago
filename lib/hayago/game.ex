defmodule Hayago.Game do
  @moduledoc """
  A struct to describe the game's history, and functions to progress the game.

  ## Attributes

  ### History

  The *history* attribute contains a list of `Hayago.State` structs, where the
  first element in the list is the current state. Whenever a move is made, a
  new state is prepended to the list. The history attbibute initally holds a
  single empty State to represent the empty board.

  ### Index

  The *index* represents the current index in the history list. On
  initialization, the index is 0, as the current state is the first element in
  the history list. To jump back one turn, the index is increased to 1. The
  `state/1` function uses the index to get the state that corresponds to the
  index.
  """
  alias Hayago.{Game, State}
  defstruct history: [%State{}], index: 0

  @doc """
  Returns the element in the history list that corresponds to the `:index`
  attribute as the current state of the game. The index defaults to 0, so the
  first state is returned by default.

      iex> Game.state(%Game{history: [
      ...>   %Hayago.State{positions: [:black, nil, nil, nil], current: :white},
      ...>   %Hayago.State{positions: [nil, nil, nil, nil], current: :black}
      ...> ]})
      %Hayago.State{positions: [:black, nil, nil, nil],current: :white}

  If the index is set, it takes the element that corresponds to the index from
  the history list.

      iex> Game.state(%Game{
      ...>   history: [
      ...>     %Hayago.State{positions: [:black, nil, nil, nil], current: :white},
      ...>     %Hayago.State{positions: [nil, nil, nil, nil], current: :black}
      ...>   ],
      ...>   index: 1
      ...> })
      %Hayago.State{positions: [nil, nil, nil, nil],current: :black}
  """
  def state(%Game{history: history, index: index}) do
    Enum.at(history, index)
  end

  @doc """
  Places a new stone on the board by prepending a new state to the history. The
  new state is created by calling `Hayago.State.place/2` and passing the
  current state, and the position passed to `place/2`.

      iex> Game.place(%Game{history: [%Hayago.State{positions: [nil, nil, nil, nil], current: :black}]}, 0)
      %Game{history: [
        %Hayago.State{positions: [:black, nil, nil, nil], current: :white},
        %Hayago.State{positions: [nil, nil, nil, nil], current: :black}
      ]}

  If the Game's `:index` attribute is higher than 0, the history is sliced
  before prepending the new state, to allow the game to branch off its history
  when it's reverted.

      iex> Game.place(%Game{
      ...>     history: [
      ...>       %Hayago.State{positions: [:black, nil, nil, nil], current: :white},
      ...>       %Hayago.State{positions: [nil, nil, nil, nil], current: :black}
      ...>     ],
      ...>     index: 1
      ...>   },
      ...>   1
      ...> )
      %Game{history: [
        %Hayago.State{positions: [nil, :black, nil, nil], current: :white},
        %Hayago.State{positions: [nil, nil, nil, nil], current: :black}
      ]}
  """
  def place(%Game{history: history, index: index} = game, position) do
    new_state =
      game
      |> Game.state()
      |> State.place(position)

    %{game | history: [new_state | Enum.slice(history, index..-1)], index: 0}
  end

  @doc """
  Jumps in history by updating the `:index` attribute.

      iex> Game.jump(%Game{index: 0}, 1)
      %Game{index: 1}
  """
  def jump(game, destination) do
    %{game | index: destination}
  end

  @doc """
  Determines if a history index is valid for the current game.

      iex> Game.history?(%Game{}, 0)
      true

      iex> Game.history?(%Game{}, 1)
      false

      iex> Game.history?(%Game{}, -1)
      false
  """
  def history?(%Game{history: history}, index) when index >= 0 and length(history) > index do
    true
  end

  def history?(_game, _index), do: false
end
