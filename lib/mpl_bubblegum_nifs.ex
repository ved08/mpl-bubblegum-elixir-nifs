defmodule MplBubblegumNifs do
  use Rustler, otp_app: :mpl_bubblegum_nifs, crate: "mplbubblegumnifs"
  @rpc_url "https://devnet.helius-rpc.com/?api-key=53da17ee-6973-4f78-ab61-fd7a59f1cc80"

  def send_transaction(tx_hash) do
    request_body =
      %{
        jsonrpc: "2.0",
        id: 1,
        method: "sendTransaction",
        params: [tx_hash, %{encoding: "base64"}]
      }
      |> Jason.encode!()

    headers = [{"Content-Type", "application/json"}]

    case(HTTPoison.post(@rpc_url, request_body, headers)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Jason.decode!() |> IO.inspect(label: "Transaction Response")
        body

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
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

  def mint_v1_builder(_secret_key, _merkle_tree) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def transfer_builder(
        payer_secret_key,
        to_address,
        asset_id,
        owner,
        nonce,
        data_hash,
        creator_hash,
        root,
        proof,
        merkle_tree
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def create_tree_config() do
    tx_hash =
      create_tree_config_builder(
        "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG"
      )

    send_transaction(tx_hash)
  end

  def mint_v1(tree_config, merkle_tree) do
    tx_hash =
      mint_v1_builder(
        "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG",
        "BB4PeT5Vaorg9V5nqyct3dyyo3RwtZQ61FQR9JK3EnKL"
      )

    send_transaction(tx_hash)
  end

  # MplBubblegumNifs.transfer("DGckRTAtcEe25UGbtuc7xDVUSC67VeFGHNgrVy1G2uAb", "6hxBtjckJxUf9FM8V9dDq1Wux5azG2a64osiNwP1KwDN", "DLgacSweX6fmAbnzwoFnVwcuGRMwFvdCzzwhrXuE5pPc")
  def transfer(asset_id, to_address, owner) do
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
      case(HTTPoison.post(@rpc_url, request_body, headers)) do
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
      case(HTTPoison.post(@rpc_url, asset_proof_request, headers)) do
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

    tx =
      transfer_builder(
        "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG",
        to_address,
        asset_id,
        owner,
        nonce,
        data_hash,
        creator_hash,
        root,
        proof,
        merkle_tree
      )

    send_transaction(tx)
  end

  def add(_a, _b) do
    :erlang.nif_error(:nif_not_loaded)
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
  def hello do
    :world
  end
end
