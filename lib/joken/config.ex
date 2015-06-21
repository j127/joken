defmodule Joken.Config do
  @moduledoc """
  This module defines the behaviour for the following:

   * encoding and decoding tokens
   * adding and validating claims
   * secret key used for encoding and decoding
   * the algorithm used

  The supported claims are `[:exp, :nbf, :iat, :aud, :iss, :sub, :jti]`

  The following example would use Poison for encoding and decoding
  and add and validate the `exp` claim. All other claims would not be added
  or validated.

  Ex:

      defmodule My.Config.Module do
        @behaviour Joken.Config

        def secret_key() do
          Application.get_env(:app, :secret_key)
        end

        def algorithm() do
          :H256
        end

        def encode(map) do
          Poison.encode!(map)
        end

        def decode(binary) do
          Poison.decode!(binary, keys: :atoms!)
        end

        def claim(:exp, payload) do
          12345678
        end

        def claim(_, _) do
          nil
        end

        def validate_claim(:exp, payload) do
          Joken.Config.validate_time_claim(payload, :exp, "Token expired", fn(expires_at, now) -> expires_at > now end)
        end

        def validate_claim(_, _) do
          :ok
        end
      end
  """
  use Behaviour

  @doc """
  Returns the algorithm used
  """
  defcallback algorithm() :: Joken.algorithm


  @doc """
  Returns the secret key used for encoding and decoding
  """
  defcallback secret_key() :: String.t

  @doc """
  Adds the specified claim to the payload.

  If nil is returned, then the claim will not be added to the
  payload. Otherwise, the value returned will be added to the payload
  """
  defcallback claim(Atom.t, Joken.payload) :: nil | any

  @doc """
  Validates the claim on the payload.

  Returns `:ok` if the claim is validated correctly or
  `{:error, message} if it does not
  """
  defcallback validate_claim(Atom.t, Joken.payload) :: :ok | {:error, String.t}

  @doc """
  encode can take either a map or a keyword list or both and return a string.   
  """
  defcallback encode(Joken.payload) :: String.t
  
  @doc """
  decode can take a string and return a map or a keyword list. 
  """
  defcallback decode(String.t) :: Joken.payload


  @doc """
  Helper function for validating time claims (exp, nbf, iat)
  """
  def validate_time_claim(payload, key, error_msg, validate_time_fun) do
    key_found? = case payload do
      p when is_map(p) ->
        Map.has_key?(payload, key)
      _ ->
        Keyword.has_key?(payload, key)
    end

    current_time = get_current_time()

    cond do
      key_found? and validate_time_fun.(payload[key], current_time) ->
        :ok
      key_found? and !validate_time_fun.(payload[key], current_time) ->
        {:error, error_msg}
      true ->
        :ok      
    end
  end


  @doc """
  Helper function for validating non-time claims
  """
  def validate_claim(payload, key_to_check, value, full_name) do
    key_found? = case payload do
      p when is_map(p) ->
        Map.has_key?(payload, key_to_check)
      _ ->
        Keyword.has_key?(payload, key_to_check)
    end

    cond do
      value == nil ->
        :ok      
      key_found? and payload[key_to_check] == value ->
        :ok
      key_found? and payload[key_to_check] != value ->
        {:error, "Invalid #{full_name}"}
      !key_found? ->
        {:error, "Missing #{full_name}"}
      true ->
        :ok       
    end
  end

  @doc """
  Helper function to get the current time
  """
  def get_current_time() do
    {mega, secs, _} = :os.timestamp()
    mega * 1000000 + secs
  end
end