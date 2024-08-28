defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, 1000)
    {:ok, assign(socket, score: 0, message: "Make a guess:", time: time(), number_to_guess: number_to_guess())}
  end

  def time() do
    DateTime.utc_now() |> DateTime.truncate(:second) |> to_string() |> String.replace("Z", "")
  end

  def number_to_guess() do
    Enum.random(1..10) |> Integer.to_string()
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold">Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
      It's <%= @time %>
    </h2>
    <br />
    <h2>
      <%= for n <- 1..10 do %>
        <.link
          class="bg-blue-500 hover:bg-blue-700
    text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
          phx-click="guess"
          phx-value-number={n}
        >
          <%= n %>
        </.link>
      <% end %>
    </h2>
    """
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    number_to_guess = socket.assigns.number_to_guess

    case guess do
      ^number_to_guess ->
        message = "Your guess: #{guess}. Correct!"
        score = socket.assigns.score + 1
        {:noreply, assign(socket, score: score, message: message, number_to_guess: number_to_guess())}
      _ ->
        message = "Your guess: #{guess}. Wrong. Guess Again!"
        score = socket.assigns.score - 1
        {:noreply, assign(socket, score: score, message: message)}
    end
  end

  def handle_info(:tick, socket) do
    time = time()
    Process.send_after(self(), :tick, 1000)
    {:noreply, assign(socket, time: time)}
  end
end
