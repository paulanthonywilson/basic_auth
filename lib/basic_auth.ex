defmodule BasicAuth do
  def init(options) do
    realm    = Keyword.fetch!(options, :realm)
    username = Keyword.fetch!(options, :username)
    password = Keyword.fetch!(options, :password)
    %{realm: realm, username: username, password: password}
  end

  def call(conn, options) do
    header_content = Plug.Conn.get_req_header(conn, "authorization")

    if header_content |> valid_credentials?(options) do
      conn
    else
      conn
      |> send_unauthorized_response(options[:realm])
    end
  end

  defp valid_credentials?(["Basic " <> encoded_string], options) do
    Base.decode64!(encoded_string) == "#{options[:username]}:#{options[:password]}"
  end

  # Handle scenarios where there are no basic auth credentials supplied
  defp valid_credentials?(_credentials, _options) do
    false
  end

  defp send_unauthorized_response(conn, realm) do
    Plug.Conn.put_resp_header(conn, "www-authenticate", "Basic realm=\"#{realm}\"")
    |> Plug.Conn.send_resp(401, "401 Unauthorized")
    |> Plug.Conn.halt
  end
end
