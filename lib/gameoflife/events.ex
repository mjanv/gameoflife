defmodule Gameoflife.Events do
  @moduledoc false

  defmodule Tick do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            t: integer()
          }

    defstruct [:w, :t]
  end

  defmodule Tock do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            t: integer()
          }

    defstruct [:w, :t]
  end

  defmodule Ping do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            x: integer(),
            y: integer(),
            t: integer()
          }

    defstruct [:w, :x, :y, :t]
  end

  defmodule On do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            x: integer(),
            y: integer(),
            t: integer()
          }

    defstruct [:w, :x, :y, :t]
  end

  defmodule Off do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            x: integer(),
            y: integer(),
            t: integer()
          }

    defstruct [:w, :x, :y, :t]
  end

  defmodule Dead do
    @moduledoc false

    @type t() :: %__MODULE__{
            w: String.t(),
            x: integer(),
            y: integer(),
            t: integer()
          }

    defstruct [:w, :x, :y, :t]
  end
end
