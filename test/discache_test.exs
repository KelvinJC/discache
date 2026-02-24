defmodule DiscacheTest do
  use ExUnit.Case
  doctest Discache

  test "has_key? returns true or false" do
    value = Discache.has_key?(:user_cache)
    assert is_boolean(value)
  end

  test "has_key? returns false for uncached keys" do
    assert Discache.has_key?(:not_yet) == false
  end

  test "put/2 successful" do
    assert Discache.put(:user_cache, "user:123") == :ok
  end

  test "get/1 successful" do
    assert Discache.put(:get_cache, "user:123") == :ok
    assert Discache.get(:get_cache) == {:ok, "user:123"}
  end
end
