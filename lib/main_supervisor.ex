defmodule MainSupervisor do
  use Supervisor

  def start_link(init_arg \\ :ok) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      %{
        id: Reducer,
        start: {Reducer, :start_link, [Reducer]}
      },
      WorkerPoolSupervisor.get_specification(:formatter, 3),
      WorkerPoolSupervisor.get_specification(:sentiment_scorer, 3),
      WorkerPoolSupervisor.get_specification(:engagement_ratio_scorer, 3),
      {LoadBalancer, :ok},
      %{
        id: :reader1,
        start: {Reader, :start_link, [:reader1, "localhost:4000/tweets/1"]}
      },
      %{
        id: :reader2,
        start: {Reader, :start_link, [:reader2, "localhost:4000/tweets/2"]}
      }
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
