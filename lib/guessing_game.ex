defmodule GuessingGame do
  use Application

  def start(_type, _args) do
    Task.start_link(fn -> play() end)
  end

  def play do
    with :ok <- IO.puts("Let's play a guessing game! Enter a number between 1 to 5. Type `quit` to quit."),
         number <- :rand.uniform(5)
    do
      case loop_guess(number) do
        :ok ->
          IO.puts("You guessed the number correctly! It was " <> Integer.to_string(number) <> ".")
          case ask_play_again() do
            :yes -> play()
            :no -> IO.puts("Thanks for playing!")
          end
        :quit ->
          IO.puts("Goodbye!")
        {:error, reason} ->
          IO.puts("Unexpected error: " <> reason)
      end
    end
  end

  def ask_play_again do
    with :ok <- IO.puts("Do you want to play again? [Y/N]")
    do
      case IO.read(:line) do
        "Y\n" -> :yes
        "y\n" -> :yes
        _ -> :no
      end
    end
  end

  def loop_guess(number) do
    case guess(number) do
      {:error, :incorrect_guess} ->
        IO.puts("Incorrect guess. Try again!")
        loop_guess(number)
      {:error, :invalid_input} ->
        IO.puts("Invalid input. Try again!")
        loop_guess(number)
      other -> other
    end
  end

  def guess(number) do
    case IO.read(:line) do
      :eof -> :quit
      "quit\n" -> :quit
      {:error, reason} -> {:error, reason}
      data ->
        with {guessed_number, _} <- Integer.parse(data)
        do
          if guessed_number == number do
            :ok
          else
            {:error, :incorrect_guess}
          end
        else
          _ -> {:error, :invalid_input}
        end
    end
  end
end
