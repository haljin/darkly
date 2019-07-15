defmodule DarklyTest do
  use ExUnit.Case
  doctest Darkly

  test "greets the world" do
    assert Darkly.hello() == :world
  end
end
