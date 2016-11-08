use Mix.Config

config :basic_auth, my_auth: [
  username: "admin",
  password: "simple_password",
  realm: "Admin Area"
]

config :basic_auth, my_auth_with_system: [
  username: {:system, "USERNAME"},
  password: {:system, "PASSWORD"},
  realm:    {:system, "REALM"}
]
