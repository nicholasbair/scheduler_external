defmodule SchedulerExternal.Vault do
  use Cloak.Vault, otp_app: :scheduler_external
end

defmodule SchedulerExternal.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: SchedulerExternal.Vault
end
