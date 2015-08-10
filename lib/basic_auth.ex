defmodule BasicAuth do

  def init(options) do
    options
  end

  def call(conn, _options) do
    credentials = Plug.Conn.get_req_header(conn, "authorization")

    if credentials |> valid_credentials? do
      conn
    else
      conn
      |> send_unauthorized_response
    end
  end

  defp valid_credentials?(credentials) do
    # true
    false
  end

  defp send_unauthorized_response(conn) do
    Plug.Conn.put_resp_header(conn, "www-authenticate", "Basic realm=\"WallyWorld\"")
    |> Plug.Conn.send_resp(401, "401 Unauthorized")
    |> Plug.Conn.halt
  end
end
