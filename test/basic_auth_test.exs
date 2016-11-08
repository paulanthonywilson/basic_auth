defmodule BasicAuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule DemoPlug do
    defmacro __using__(auth_config) do
      quote bind_quoted: [auth_config: auth_config] do
        use Plug.Builder
        plug BasicAuth, use_config: {:basic_auth, auth_config}
        plug :index
        defp index(conn, _opts), do: conn |> send_resp(200, "OK")
      end
    end
  end

  describe "credential checking" do
    defmodule SimpleDemoPlug do
      use DemoPlug, :my_auth
    end

    test "no credentials returns a 401" do
      conn = conn(:get, "/")
      |> SimpleDemoPlug.call([])

      assert conn.status == 401
      assert Plug.Conn.get_resp_header(conn, "www-authenticate") == [ "Basic realm=\"Admin Area\""]
    end

    test "invalid credentials returns a 401" do
      header_content = "Basic " <> Base.encode64("bad:credentials")

      conn = conn(:get, "/")
      |> put_req_header("authorization", header_content)
      |> SimpleDemoPlug.call([])

      assert conn.status == 401
    end

    test "incorrect header returns a 401" do
      header_content = "Banana " <> Base.encode64("admin:simple_password")

      conn = conn(:get, "/")
      |> put_req_header("authorization", header_content)
      |> SimpleDemoPlug.call([])

      assert conn.status == 401
    end

    test "valid credentials returns a 200" do
      header_content = "Basic " <> Base.encode64("admin:simple_password")

      conn = conn(:get, "/")
      |> put_req_header("authorization", header_content)
      |> SimpleDemoPlug.call([])

      assert conn.status == 200
    end
  end

  describe "reading config from System environment" do
    defmodule SimpleDemoPlugWithSystem do
      use DemoPlug, :my_auth_with_system
    end


    test "username and password" do
      System.put_env("USERNAME", "bananauser")
      System.put_env("PASSWORD", "bananapassword")

      header_content = "Basic " <> Base.encode64("bananauser:bananapassword")
      conn = conn(:get, "/")
      |> put_req_header("authorization", header_content)
      |> SimpleDemoPlugWithSystem.call([])

      assert conn.status == 200
    end

    test "realm" do
      System.put_env("REALM", "Banana")
      conn = conn(:get, "/")
      |> SimpleDemoPlugWithSystem.call([])
      assert Plug.Conn.get_resp_header(conn, "www-authenticate") == [ "Basic realm=\"Banana\""]
    end
  end

  # test "config value not being set error" do
  #   Application.put_env(:myapp, :basic_auth, [username: "yada"])
  #   header_content = "Basic " <> Base.encode64("admin:simple_password")
  #   conn = conn(:get, "/")
  #   |> put_req_header("authorization", header_content)

  #   assert_raise ArgumentError, "configuration value for option :password is not set", fn ->
  #     SimpleDemoPlug.call(conn, [])
  #   end
  # end

end
