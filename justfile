default: code-quality test

code-quality:
    mix format
    mix credo --strict

test:
    mix test

shutdown:
    flyctl scale count 0

small:
    flyctl scale vm shared-cpu-1x --memory=2048
    flyctl scale count 1

large:
    flyctl scale vm dedicated-cpu-8x --memory=32768
    flyctl scale count 1