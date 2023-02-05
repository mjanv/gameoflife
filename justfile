default: code-quality test

code-quality:
    mix format
    mix credo --strict

test:
    mix test

benchmark:
    mix test --trace --include benchmark

node name port:
    PORT={{port}} iex --sname {{name}} -S mix phx.server

a:
    PORT=4000 iex --erl '+P 1200000' --sname a -S mix phx.server

b:
    PORT=4001 iex --sname b -S mix phx.server

c:
    PORT=4002 iex --sname c -S mix phx.server

deploy:
    flyctl deploy . --region cdg --now

shutdown:
    flyctl scale count 0

small:
    flyctl scale vm shared-cpu-1x --memory=2048
    flyctl scale count 1

large:
    flyctl scale vm dedicated-cpu-8x --memory=32768
    flyctl scale count 1