defmodule VolleyFireTest do
  use ExUnit.Case
  doctest VolleyFire

  test "rank returns less than count tasks" do
    silly = Enum.map(1..20, fn(x) -> fn -> x end end)
    assert Enum.count(VolleyFire.rank(silly,3)) <= 3
  end

  test "roll returns less than count tasks" do
    silly = Enum.map(1..20, fn(x) -> fn -> x end end)
    assert Enum.count(VolleyFire.roll(silly,3)) <= 3
  end

end
