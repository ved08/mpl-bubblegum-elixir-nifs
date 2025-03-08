defmodule MplBubblegum do
  use Rustler, otp_app: :mpl_bubblegum_nifs, crate: "mplbubblegumnifs"
  alias MplBubblegum.Connection

  def send_transaction(tx_hash) do
    rpc_url = MplBubblegum.Connection.get_rpc_url()

    request_body =
      %{
        jsonrpc: "2.0",
        id: 1,
        method: "sendTransaction",
        params: [tx_hash, %{encoding: "base64"}]
      }
      |> Jason.encode!()

    headers = [{"Content-Type", "application/json"}]

    case(HTTPoison.post(rpc_url, request_body, headers)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, data} = Jason.decode(body)
        data["result"]

      {:error, %HTTPoison.Response{status_code: status, body: body}} ->
        IO.puts("Error: HTTP #{status}")
        IO.inspect(body)
        body

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Request failed:")
        IO.inspect(reason)
        reason
    end
  end

  def create_tree_config_builder(_secret_key) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def mint_v1_builder(_secret_key, _merkle_tree, _name, _symbol, _uri, _basis, _share) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def transfer_builder(
        _payer_secret_key,
        _to_address,
        _asset_id,
        _nonce,
        _data_hash,
        _creator_hash,
        _root,
        _proof,
        _merkle_tree
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def create_tree_config() do
    key = Connection.get_secret_key()
    [serialized_tx, merkle_tree] = create_tree_config_builder(key)
    tx = send_transaction(serialized_tx)
    merkle_tree
  end

  def mint_v1(merkle_tree, name, symbol, uri, basis, share) do
    # "BB4PeT5Vaorg9V5nqyct3dyyo3RwtZQ61FQR9JK3EnKL"
    key = Connection.get_secret_key()

    tx_hash =
      mint_v1_builder(
        key,
        merkle_tree,
        name,
        symbol,
        uri,
        basis,
        share
      )

    tx = send_transaction(tx_hash)
    tx
  end

  def transfer(asset_id, to_address) do
    rpc_url = MplBubblegum.Connection.get_rpc_url()

    request_body =
      %{
        "id" => "test",
        "jsonrpc" => "2.0",
        "method" => "getAssetBatch",
        "params" => %{
          "ids" => [asset_id]
        }
      }
      |> Jason.encode!()

    headers = [{"Content-Type", "application/json"}]

    response =
      case(HTTPoison.post(rpc_url, request_body, headers)) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> Jason.decode!()

        {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          IO.puts("Error: HTTP #{status}")
          IO.inspect(body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("Request failed:")
          IO.inspect(reason)
      end

    asset_proof_request =
      %{
        "id" => "test",
        "jsonrpc" => "2.0",
        "method" => "getAssetProofBatch",
        "params" => %{
          "ids" => [asset_id]
        }
      }
      |> Jason.encode!()

    response2 =
      case(HTTPoison.post(rpc_url, asset_proof_request, headers)) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> Jason.decode!()

        {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          IO.puts("Error: HTTP #{status}")
          IO.inspect(body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("Request failed:")
          IO.inspect(reason)
      end

    [data1] = response["result"]
    proof = response2["result"][asset_id]["proof"]
    root = response2["result"][asset_id]["root"]
    compression = data1["compression"]
    creator_hash = compression["creator_hash"]
    data_hash = compression["data_hash"]
    nonce = compression["leaf_id"]
    merkle_tree = compression["tree"]

    key = Connection.get_secret_key()

    tx =
      transfer_builder(
        key,
        to_address,
        asset_id,
        nonce,
        data_hash,
        creator_hash,
        root,
        proof,
        merkle_tree
      )

    send_transaction(tx)
  end

  @moduledoc """
  Documentation for `MplBubblegumNifs`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MplBubblegumNifs.hello()
      :world

  """
end
