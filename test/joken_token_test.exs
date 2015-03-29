defmodule Joken.Token.Test do
  use ExUnit.Case

  @moduledoc """
  Tests calling the Joken.Token module directly
  """

  @secret "test"
  @payload %{ name: "John Doe" }

  # generated at jwt.io with header {"typ": "JWT", "alg": "HS256"}, claim {"name": "John Doe"}, secret "test"
  @unsorted_header_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.B3tqUk6UdT8K5AQUGdYFXPj7R7_JznRi5PRrv_N7d1I"

  @poison_json_module Joken.TestPoison
  @jsx_json_module Joken.TestJsx

  test "encode and decode with HS256 (Poison)" do
    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload)
    assert(token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.B3tqUk6UdT8K5AQUGdYFXPj7R7_JznRi5PRrv_N7d1I")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @poison_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "encode and decode with HS384 (Poison)" do
    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS384)
    assert(token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzM4NCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.zDrtMUaPYXpFdESkmnjzMgDZsHC6LObDfrEdryAzZ981r77Td2BZ61rx09tsJFvP")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @poison_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "encode and decode with HS512 (Poison)" do
    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS512)
    assert(token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.olXW3I_OpLs9bfthg49kVIgUFHTjLCoCEGthWICMd2DZyGyIn0eAcjF3KuMA29Yb6W9kyAYf1dKn7sPwEajcmA")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @poison_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "decode token generated with un-sorted keys (Poison)" do
    {:ok, _} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS512)
    {:ok, decoded_payload} = Joken.Token.decode(@secret, @poison_json_module, @unsorted_header_token) 
    assert(@payload == decoded_payload) 
  end

  test "signature validation (Poison)" do
    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload)
    assert(token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.B3tqUk6UdT8K5AQUGdYFXPj7R7_JznRi5PRrv_N7d1I")
    {:ok, _} = Joken.Token.decode(@secret, @poison_json_module, token) 

    new_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.3fazvmF342WiHp5uhY-wkWArn-YJxq1IO7Msrtfk-OD"
    {:error, mesg} = Joken.Token.decode(@secret, @poison_json_module, new_token) 
    assert(mesg == "Invalid signature") 
  end

  test "expiration (exp)" do
    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS256, %{ exp: Joken.Utils.get_current_time() + 300 })
    {status, _} = Joken.Token.decode(@secret, @poison_json_module, token)
    assert(status == :ok) 

    {:ok, token} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS256, %{ exp: Joken.Utils.get_current_time() - 300 })
    {status, mesg} = Joken.Token.decode(@secret, @poison_json_module, token)
    assert(status == :error) 
    assert(mesg == "Token expired") 
  end

  test "error with invalid algorithm" do
    {:error, message} = Joken.Token.encode(@secret, @poison_json_module, @payload, :HS1024)
    assert message == "Unsupported algorithm"
  end
  
  test "encode and decode with HS256 (JSX)" do
    {:ok, token} = Joken.Token.encode(@secret, @jsx_json_module, @payload)
    assert(token == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.3fazvmF342WiHp5uhY-wkWArn-YJxq1IO7Msrtfk-OQ")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @jsx_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "encode and decode with HS384 (JSX)" do
    {:ok, token} = Joken.Token.encode(@secret, @jsx_json_module, @payload, :HS384)
    assert(token == "eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.YOH6U5Ggk5_o5B7Dg3pacaKcPkrbFEX-30-trLV6C6wjTHJ_975PXLSEzebOSP8k")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @jsx_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "encode and decode with HS512 (JSX)" do
    {:ok, token} = Joken.Token.encode(@secret, @jsx_json_module, @payload, :HS512)
    assert(token == "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.zi1zohSNwRdHftnWKE16vE3VmbGFtG27LxbYDXAodVlX7T3ATgmJJPjluwf2SPKJND2-O7alOq8NWv6EAnWWyg")

    {:ok, decoded_payload} = Joken.Token.decode(@secret, @jsx_json_module, token) 
    assert(@payload == decoded_payload) 
  end

  test "decode token generated with un-sorted keys (JSX)" do
    {:ok, _} = Joken.Token.encode(@secret, @jsx_json_module, @payload, :HS512)
    {:ok, decoded_payload} = Joken.Token.decode(@secret, @jsx_json_module, @unsorted_header_token) 
    assert(@payload == decoded_payload) 
  end

  test "signature validation (JSX)" do
    {:ok, token} = Joken.Token.encode(@secret, @jsx_json_module, @payload)
    assert(token == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.3fazvmF342WiHp5uhY-wkWArn-YJxq1IO7Msrtfk-OQ")
    {:ok, _} = Joken.Token.decode(@secret, @jsx_json_module, token) 

    new_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiSm9obiBEb2UifQ.3fazvmF342WiHp5uhY-wkWArn-YJxq1IO7Msrtfk-OD"
    {:error, mesg} = Joken.Token.decode(@secret, @jsx_json_module, new_token) 
    assert(mesg == "Invalid signature") 
  end
end