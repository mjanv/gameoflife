defmodule Gameoflife.Events do
  @moduledoc false

  defmodule Tick do
    @moduledoc false

    defstruct [:t]
  end

  defmodule Tock do
    @moduledoc false

    defstruct [:t]
  end

  defmodule Ping do
    @moduledoc false

    defstruct [:t]
  end

  defmodule On do
    @moduledoc false

    defstruct [:t, :x, :y]
  end

  defmodule Off do
    @moduledoc false

    defstruct [:t, :x, :y]
  end
end
