# Gameoflife

## Step 1 - Project creation

```bash
mix phx.new . --app gameoflife --no-ecto --no-mailer --no-gettext
mix deps.get
mix phx.server
```

## Step 2 - Tailwind

[Tailwind Phoenix guide](https://tailwindcss.com/docs/guides/phoenix)

```bash
mix deps.get
mix tailwind.install
mix phx.server
```

## Step 3 - LiveView for simple cell

https://daily-dev-tips.com/posts/tailwind-css-responsive-square-divs/

## Time estimation

- Step 1: Project creation = 10 minutes.
- Step 2: Tailwind = 10 minutes.
- Step 3: Liveview for simple cell = 20 minutes.
