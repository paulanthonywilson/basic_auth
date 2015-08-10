# BasicAuth

This is an Elixir Plug for adding basic authentication into an application.

## How to use



Add into the top of a controller, or into a router pipeline a plug declaration like:
```elixir
plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"
```
