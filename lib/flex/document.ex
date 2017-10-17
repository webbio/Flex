# defmodule PostStage do
#   use GenStage
#   import Ecto.Query
# 
#   def start_link(number) do
#     GenStage.start_link(__MODULE__, number)
#   end
# 
#   def init(counter) do
#     {:producer, counter}
#   end
# 
#   def handle_demand(demand, counter) when demand > 0 do
#     events = (from p in Roll.Products.Product, offset: ^counter, limit: ^demand) |> Roll.Repo.all
#     if length(events) == 0 do
#       {:stop, :normal, counter + demand}
#     else
#       {:noreply, events, counter + demand}
#     end
#   end
# end

defmodule Flex.Document do
  # def bulk_index(index, schema, repo) do
  #   {:ok, stage} = PostStage.start_link(0)
  #   stage
  #   |> Flow.from_stage(min_demand: 1_000, max_demand: 10_000)
  #   |> Flow.map(fn record ->
  #     [%{index: %{_id: record.id}}, mapping(record)]
  #   end)
  #   |> batch(500)
  #   |> Flow.map_state(fn lines ->
  #     Enum.reduce(lines, "", fn (line, payload) ->
  #       payload <> Poison.encode!(line) <> "\n"
  #     end)
  #   end)
  #   |> Flow.each_state(fn bulk ->
  #     Flex.HTTP.post "/#{index}/#{index}/_bulk", bulk
  #   end)
  #   |> Flow.run
  # end
  # 
  # def mapping(product) do
  #   %{
  #     name: product.name,
  #     status: product.status,
  #     foo: product.id > 50_000
  #   }
  # end
  # 
  # def batch(flow, count) do
  #   flow
  #   |> Flow.partition(window: Flow.Window.count(count))
  #   |> Flow.reduce(fn -> [] end, fn line, lines -> line ++ lines end)
  # end
end