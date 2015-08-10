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
