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

  test "no credentials returns a 401" do
    conn = conn(:get, "/")
    |> DemoPlug.call([])

    assert conn.status == 401
    assert Plug.Conn.get_resp_header(conn, "www-authenticate") == [ "Basic realm=\"Admin Area\""]
  end

  test "invalid credentials returns a 401" do
    header_content = "Basic " <> Base.encode64("bad:credentials")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> DemoPlug.call([])

    assert conn.status == 401
  end

  test "incorrect header returns a 401" do
    header_content = "Banana " <> Base.encode64("admin:secret")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> DemoPlug.call([])

    assert conn.status == 401
  end

  test "valid credentials returns a 200" do
    header_content = "Basic " <> Base.encode64("admin:secret")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> DemoPlug.call([])

    assert conn.status == 200
  end

  defmodule DemoPlugApplicationConfigured do
    use Plug.Builder

    plug BasicAuth, use_config: {:myapp, :basic_auth}

    plug :index
    defp index(conn, _opts), do: conn |> send_resp(200, "OK")
  end

  test "reading credentials from application config happens at runtime" do
    {_realm, username, password} = setup_application_config

    header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    conn = conn(:get, "/")
    |> put_req_header("authorization", header_content)
    |> DemoPlugApplicationConfigured.call([])

    assert conn.status == 200
  end

  test "realm from application config is read at runtime" do
    {_realm, _username, _password} = setup_application_config

    conn = conn(:get, "/")
    |> DemoPlugApplicationConfigured.call([])

    assert conn.status == 401
    assert Plug.Conn.get_resp_header(conn, "www-authenticate") == [ "Basic realm=\"my realm\""]
  end

  defp setup_application_config do
    appname = :myapp
    config = [username: username = "user",
              password: password = "passw0rd",
              realm: realm = "my realm"]

    Application.put_env(appname, :basic_auth, config)

    {realm, username, password}
  end
end
