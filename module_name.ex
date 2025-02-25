# module_name.ex
defmodule ModuleName do
  def hello do
    IO.puts("Hello, world!")
  end

  def max(a, b) do
    if a >= b, do: a, else: b
  end

  def call_status(call) do
    cond do
      call.ended_at != nil -> :ended
      call.started_at != nil -> :started
      true -> :pending
    end
  end

  def max_case(a, b) do
    case a >= b do
      true -> a
      false -> b
      _ -> nil # the default case
    end
  end

  defp extract_login(%{"login" => login}), do: {:ok, login}
  defp extract_login(_), do: {:error, "login missing"}

  defp extract_email(%{"email" => email}), do: {:ok, email}
  defp extract_email(_), do: {:error, "email missing"}

  defp extract_password(%{"password" => password}), do: {:ok, password}
  defp extract_password(_), do: {:error, "password missing"}

  def extract_user(user) do
    with {:ok, login} <- extract_login(user),
        {:ok, email} <- extract_email(user),
        {:ok, password} <- extract_password(user) do
      {:ok, %{login: login, email: email, password: password}}
    end
  end
end
