defmodule BasicAuth do

  def init(options) do
    options
  end

  def call(conn, _options) do
    Plug.Conn.put_resp_header(conn, "www-authenticate", "Basic realm=\"WallyWorld\"")
    |> Plug.Conn.send_resp(401, "401 Unauthorized")
    |> Plug.Conn.halt
  end
end
