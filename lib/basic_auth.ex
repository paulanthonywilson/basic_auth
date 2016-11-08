defmodule BasicAuth do
  defstruct username: nil, password: nil, realm: nil

  def init([use_config: {app, config_key} = config_options] = options) do
    configuration = Application.fetch_env!(app, config_key)

    %__MODULE__{username: config_option(config_options, configuration, :username),
                password: config_option(config_options, configuration, :password),
                realm:    config_option(config_options, configuration, :realm)}
    options
  end

  defp config_option({app, config_key}, configuration, key) do
    Keyword.get(configuration, key) ||
      raise ArgumentError, """
      BasicAuth configuration value missing, in #{inspect app}, #{inspect config_key}, for option #{inspect key}.
      """
  end

  def call(conn, options) do
    header_content = Plug.Conn.get_req_header(conn, "authorization")

    if valid_credentials?(header_content, options) do
      conn
    else
      conn
      |> send_unauthorized_response(option_value(options, :realm))
    end
  end

  defp valid_credentials?(["Basic " <> encoded_string], options) do
    Base.decode64!(encoded_string)  == "#{option_value(options, :username)}:#{option_value(options, :password)}"
  end
  defp valid_credentials?(_credentials, _options), do: false

  defp send_unauthorized_response(conn, realm) do
    Plug.Conn.put_resp_header(conn, "www-authenticate", "Basic realm=\"#{realm}\"")
    |> Plug.Conn.send_resp(401, "401 Unauthorized")
    |> Plug.Conn.halt
  end

  defp option_value([use_config: {app, config_key}], option_key) do
    Application.fetch_env!(app, config_key)
    |> Keyword.get(option_key)
    |> to_value || raise ArgumentError, "configuration value for option #{inspect option_key} is not set"
  end

  defp to_value({:system, env_var}), do: System.get_env(env_var)
  defp to_value(value), do: value
end
