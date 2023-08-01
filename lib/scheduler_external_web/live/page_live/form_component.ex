defmodule SchedulerExternalWeb.PageLive.FormComponent do
  use SchedulerExternalWeb, :live_component

  alias SchedulerExternal.Pages

  @impl true
  # Don't show the intregation dropdown during edit, as a user cannot change the integration after creation
  def render(%{action: :edit} = assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="page-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:public?]} type="checkbox" label="Public?" />
        <.input field={@form[:cost]} type="number" label="Cost" />
        <.input field={@form[:integration_id]} type="hidden" />
        <.input field={@form[:vendor_id]} type="hidden" />
        <.input field={@form[:user_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Page</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="page-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:public?]} type="checkbox" label="Public?" />
        <.input field={@form[:cost]} type="number" label="Cost" />
        <.input field={@form[:integration_id]} type="select" label="Integration" options={@page.integrations} />
        <.input field={@form[:profile_id]} type="select" label="Profile" options={@page.profiles} />
        <.input field={@form[:user_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Page</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{page: page} = assigns, socket) do
    changeset = Pages.change_page(page)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset =
      socket.assigns.page
      |> Pages.change_page(page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, socket.assigns.action, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    case Pages.update_page(socket.assigns.page, page_params) do
      {:ok, page} ->
        notify_parent({:saved, page})

        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_page(socket, :new, page_params) do
    case Pages.create_page(page_params) do
      {:ok, page} ->
        notify_parent({:saved, page})

        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
