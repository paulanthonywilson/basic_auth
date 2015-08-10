# BasicAuth

This is an Elixir Plug for adding basic authentication into an application.

## How to use

Add the package as a dependency in your Elixir project using something along the lines of:
```
  defp deps do
    [{:basic_auth, ">= 0.0.1"}]
  end
```

Add into the top of a controller, or into a router pipeline a plug declaration like:
```elixir
plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"
```

## Testing controllers with Basic Auth

This is still an evolving process for me, but my current approach is to keep the basic auth credentials stored as environment variables, and reference these variables in both the plug declaration, and in the tests.

### Using ENV vars

So, similar to the above example, we can set the plug config to look like:
```elixir
plug BasicAuth, realm: "Admin Area",
                username: System.get_env("BASIC_AUTH_NAME"),
                password: System.get_env("BASIC_AUTH_PASSWORD")
```

Where `BASIC_AUTH_NAME` and `BASIC_AUTH_PASSWORD` are just environment variables set in my local `.bash_profile`.

### Update Tests to insert a basic authentication header

At the top of my controller I have something that looks like:

```elixir
  @username System.get_env("BASIC_AUTH_NAME")
  @password System.get_env("BASIC_AUTH_PASSWORD")

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end
```

Then for any tests, I can simply pipe in this helper method to the connection process:
```elixir
test "GET /" do
  conn = conn()
    |> using_basic_auth(@username, @password)
    |> get("/admin/users")

  assert html_response(conn, 200) =~ "Users"
end
```

And a test case without basic auth for completeness:
```elixir
test "GET /" do
  conn = conn()
    |> get("/admin/users")

  assert html_response(conn, 401) =~ "401 Unauthorized"
end
```
