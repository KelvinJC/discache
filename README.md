# Discache

**A lightweight, distributed in-memory cache for Elixir applications.**

Discache provides a simple key-value storage interface that automatically distributes data across multiple nodes in an Elixir cluster using consistent hashing. 
Built on the BEAM's distribution capabilities, it offers fault-tolerant caching with minimal configuration.


Features
- Transparent Distribution: Keys are automatically distributed across cluster nodes using consistent hashing
- Zero Configuration: Works out-of-the-box with your existing Elixir cluster
- Fault Tolerant: Continues operating during node failures (with configurable replication)
- Simple API: Familiar get/put semantics with pattern matching friendly return values
- Lightweight: Minimal dependencies, just Elixir/OTP and ([:ex_hash_ring](https://github.com/discord/ex_hash_ring))



## Installation

Note: 
Discache is not yet published to Hex.pm. For now, you can depend on the GitHub version.

Add discache to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:discache, github: "kelvinjc/discache"}
  ]
end
```
Then run mix deps.get to fetch the dependency.


## Usage

### Basic Operations

#### ``` Store a value ```
```elixir
:ok = Discache.put("user:123", %{name: "Jane", email: "jane@example.com"})
```

#### ``` Retrieve a value ```
```elixir
case Discache.get(:user_cache, "user:123") do
  {:ok, user} -> IO.inspect(user)
  {:error, :not_found} -> IO.puts("User not found in cache")
end
```

#### ``` Delete a value ```
```elixir
:ok = Discache.delete(:user_cache, "user:123")
```

#### ``` Check if a key exists ```
```elixir
true = Discache.has_key?(:user_cache, "user:123")
```

## Cluster Setup
Connecting Nodes:

Discache leverages Erlang's distributed capabilities. 
You may connect your applications' nodes manually(e.g. for testing during development) or use a library like libcluster for automatic discovery.


### Manual connection (For test purposes.)
Run multiple instances of your project in separate bash terminals. 

#### Terminal 1
```
iex --name "cache1app@127.0.0.1" --cookie secret -S mix
```

#### Terminal 2 
``` 
iex --name "cache2app@127.0.0.1" --cookie secret -S mix
```

Manual connection (in Terminal 2)
```
Node.connect(:"cache1app@127.0.0.1")
```

## Automatic node clustering using Libcluster
Libcluster is a library that provides a mechanism for automatically forming clusters of Erlang nodes, with either static or dynamic node membership. 
It provides a pluggable "strategy" system, with a variety of strategies provided out of the box.

For more information, checkout the library [here](https://github.com/bitwalker/libcluster) 


Add libcluster to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:libcluster, "~> 3.5"}

  ]
end
```
Then run mix deps.get to fetch the dependency.


You may use the Gossip Strategy or any cluster strategy that fits your use case
```elixir
  def start(_type, _args) do
    topologies = [
      demo_cluster: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_address: "0.0.0.0",
          multicast_addr: "255.255.255.255",
          broadcast_only: true
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: YourAppName.Cluster]]},
      # ... other processes ...
    ]

    # ....
  end
```

## Acknowledgments:

Built on the shoulders of the BEAM community.


