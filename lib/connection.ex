defmodule MplBubblegum.Connection do
  use Agent

  def create_connection(secret_key, rpc_url) do
    Agent.start_link(fn -> [secret_key, rpc_url] end, name: __MODULE__)
  end

  def get_secret_key do
    Agent.get(__MODULE__, fn [key, _] -> key end)
  end

  def get_rpc_url do
    Agent.get(__MODULE__, fn [_, rpc_url] -> rpc_url end)
  end

  @moduledoc """
    Before using the library, establish a connection to Solana RPC. **Use a Helius RPC URL, as native Solana RPC does not support DAS API.**
  """
end
