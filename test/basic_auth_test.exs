defmodule BasicAuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  # Demo plug with basic auth and a simple index action
  defmodule DemoPlug do
    use Plug.Builder

    plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"

    plug :index
    defp index(conn, _opts), do: conn |> send_resp(200, "OK")
  end

  defp call(conn) do
    DemoPlug.call(conn, [])
  end

  test "no credentials returns a 401" do
    conn = conn(:get, "/")
    |> call

    assert conn.status == 401
  end

  test "invalid credentials returns a 401" do
    header_content = "Basic " <> Base.encode64("bad:credentials")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> call

    assert conn.status == 401
  end

  test "incorrect header returns a 401" do
    header_content = "Banana " <> Base.encode64("admin:secret")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> call

    assert conn.status == 401
  end

  test "valid credentials returns a 200" do
    header_content = "Basic " <> Base.encode64("admin:secret")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> call

    assert conn.status == 200
  end
end
