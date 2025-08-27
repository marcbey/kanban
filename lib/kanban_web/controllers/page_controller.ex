defmodule KanbanWeb.PageController do
  use KanbanWeb, :controller

  def home(conn, _params) do
    # Test database connectivity
    db_status = test_database_connection()

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, db_status: db_status)
  end

  defp test_database_connection do
    try do
      # Try to execute a simple query to test connectivity
      case Kanban.Repo.query("SELECT 1") do
        {:ok, _result} ->
          {:ok, "Database connection successful"}

        {:error, error} ->
          {:error, "Database query failed: #{inspect(error)}"}
      end
    rescue
      e in DBConnection.ConnectionError ->
        {:error, "Database connection error: #{e.message}"}

      e in Postgrex.Error ->
        {:error, "PostgreSQL error: #{e.message}"}

      e ->
        {:error, "Unexpected error: #{inspect(e)}"}
    end
  end
end
