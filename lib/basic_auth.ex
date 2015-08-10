defmodule BasicAuth do
  def init(options) do
    options
  end

  def call(conn, _options) do
    header_content = Plug.Conn.get_req_header(conn, "authorization")

    if header_content |> valid_credentials? do
      conn
    else
      conn
      |> send_unauthorized_response
    end
  end

  defp valid_credentials?(["Basic " <> encoded_string]) do
    Base.decode64!(encoded_string) == "admin:secret"
  end

  # Handle scenarios where there are no basic auth credentials supplied
  defp valid_credentials?(_) do
    false
  end

  defp send_unauthorized_response(conn) do
    Plug.Conn.put_resp_header(conn, "www-authenticate", "Basic realm=\"WallyWorld\"")
    |> Plug.Conn.send_resp(401, "401 Unauthorized")
    |> Plug.Conn.halt
  end
end
