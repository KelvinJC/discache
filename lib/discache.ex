defmodule Discache do
  @moduledoc """
  Discache provides a straightforward interface for in-memory key/value storage.
  """
  use GenServer
  alias ExHashRing.Ring

  # # # # # # # # #
  #   Public API   #
  # # # # # # # # #

  @spec get(any()) :: {:ok, any()} | {:error, atom()}
  def get(key) do
    case Ring.find_node(DistributionRing, key) do
      {:ok, node} ->
        response = GenServer.call({__MODULE__, node}, {:get, key})
        {:ok, response}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  @spec put(any(), any()) :: :ok
  def put(key, value) do
    case Ring.find_node(DistributionRing, key) do
      {:ok, node} ->
        GenServer.cast({__MODULE__, node}, {:put, key, value})

      {:error, _} ->
        GenServer.cast({__MODULE__, Node.self()}, {:put, key, value})
    end
  end

  @spec delete(any()) :: :ok
  def delete(key) do
    case Ring.find_node(DistributionRing, key) do
      {:ok, node} ->
        GenServer.cast({__MODULE__, node}, {:delete, key})

      {:error, _} ->
        GenServer.cast({__MODULE__, Node.self()}, {:delete, key})
    end
  end

  @doc """
  Creates a new Discache cache process.
  """
  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts , name: __MODULE__)
  end

  @doc """
  Basic initialization phase for a cache.
  """
  @spec init(any()) :: {:ok, map()}
  def init(_opts), do: {:ok, %{}}

  def handle_cast({:put, key, value}, cache) do
    {:noreply, Map.put(cache, key, value)}
  end

  def handle_cast({:delete, key}, cache) do
    {:noreply, Map.delete(cache, key)}
  end

  def handle_call({:get, key}, _from, cache) do
    {:reply, Map.get(cache, key), cache}
  end
end
