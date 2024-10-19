defmodule Gameoflife.Commands do
  @moduledoc false

  defmodule ChangeGridSize do
    @moduledoc false

    @type t() :: %__MODULE__{
            n: integer()
          }

    defstruct [:n]
  end
end
