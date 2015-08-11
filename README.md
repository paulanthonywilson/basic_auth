# BasicAuth

This is an Elixir Plug for adding basic authentication into an application.

## How to use

Add the package as a dependency in your Elixir project using something along the lines of:
```elixir
  defp deps do
    [{:basic_auth, ">= 0.0.1"}]
  end
```

Add into the top of a controller, or into a router pipeline a plug declaration like:
```elixir
plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"
```

Easy as that!

## Testing controllers with Basic Auth

This is still an evolving process for me, but my current approach is to keep the basic auth
credentials stored inside the phoenix config files e.g. `config/dev.exs`, and reference these
variables in both the plug declaration, and in the tests.

### Store credentials in config

So, similar to the above example, we can set the plug config to look like:
```elixir
plug BasicAuth, realm: "Admin Area",
                username: Application.get_env(:fakebook, :basic_auth)[:username],
                password: Application.get_env(:fakebook, :basic_auth)[:password]
```

And we can then fetch the username and password from configuration files. This has the
advantage of not hardcoding production config into our codebase:

```elixir
# dev.exs, test.exs
config :my_application_name, :basic_auth,
  username: "admin",
  password: "secret"
```

### Update Tests to insert a basic authentication header

At the top of my controller I have something that looks like:

```elixir
@username Application.get_env(:fakebook, :basic_auth)[:username]
@password Application.get_env(:fakebook, :basic_auth)[:password]

defp using_basic_auth(conn, username, password) do
  header_content = "Basic " <> Base.encode64("#{username}:#{password}")
  conn |> put_req_header("authorization", header_content)
end
```

Then for any tests, I can simply pipe in this helper method to the connection process:
```elixir
test "GET / successfully renders when basic auth credentials supplied" do
  conn = conn()
    |> using_basic_auth(@username, @password)
    |> get("/admin/users")

  assert html_response(conn, 200) =~ "Users"
end
```

And a test case without basic auth for completeness:
```elixir
test "GET / without basic auth credentials prevents access" do
  conn = conn()
    |> get("/admin/users")

  assert html_response(conn, 401) =~ "401 Unauthorized"
end
```
