defmodule MplBubblegumNifs do
  use Rustler, otp_app: :mpl_bubblegum_nifs, crate: "mplbubblegumnifs"
  @rpc_url "https://api.devnet.solana.com"

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

  def transfer_builder(_secret_key, _to_address, _merkle_tree, _index) do
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

  def transfer(index) do
    tx_hash =
      transfer_builder(
        "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG",
        "to address",
        "BB4PeT5Vaorg9V5nqyct3dyyo3RwtZQ61FQR9JK3EnKL",
        index
      )
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
