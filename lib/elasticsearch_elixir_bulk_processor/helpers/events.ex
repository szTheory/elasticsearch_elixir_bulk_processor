defmodule ElasticsearchElixirBulkProcessor.Helpers.Events do
  @doc ~S"""

  Return the size of the string in bytes

  ## Examples

    iex> ElasticsearchElixirBulkProcessor.Helpers.Events.byte_sum(["abcd", "a", "b"])
    6

    iex> ElasticsearchElixirBulkProcessor.Helpers.Events.byte_sum([])
    0

  """
  def byte_sum([]),
    do: 0

  def byte_sum(string_list) when is_list(string_list),
    do: Stream.map(string_list, &byte_size/1) |> Enum.sum()

  @doc ~S"""

  Split list of strings into first chunk of given byte size and rest of the list.

  ## Examples

    iex> ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    ...> |> ElasticsearchElixirBulkProcessor.Helpers.Events.split_first_bytes(3)
    {["0", "1", "2"], ["3", "4", "5", "6", "7", "8", "9"]}

    iex> ["00", "11", "22", "33"]
    ...> |> ElasticsearchElixirBulkProcessor.Helpers.Events.split_first_bytes(3)
    {["00", "11"], ["22", "33"]}

    iex> ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    ...> |> ElasticsearchElixirBulkProcessor.Helpers.Events.split_first_bytes(0)
    {[], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]}

  """
  def split_first_bytes(list, first_byte_size) do
    list
    |> Enum.reduce(
      {[], []},
      fn element, acc -> build_up_first_chunk_elements(element, acc, first_byte_size) end
    )
  end

  defp build_up_first_chunk_elements(element, {first, rest}, first_byte_size)
       when is_binary(element) do
    if first |> byte_sum >= first_byte_size do
      {first, rest ++ [element]}
    else
      {first ++ [element], rest}
    end
  end

  @doc ~S"""

  Split list of strings into chunks of given byte size and rest of the list.

  ## Examples

    iex> ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    ...> |> ElasticsearchElixirBulkProcessor.Helpers.Events.chunk_bytes(3)
    [["0", "1", "2"], ["3", "4", "5"], ["6", "7", "8"], ["9"]]

    iex> ["00", "11", "22", "33", "44"]
    ...> |> ElasticsearchElixirBulkProcessor.Helpers.Events.chunk_bytes(3)
    [["00", "11"], ["22", "33"], ["44"]]

  """
  def chunk_bytes(list, chunk_byte_size) do
    list
    |> Enum.reduce(
      [[]],
      fn element, acc -> build_up_chunk_elements(element, acc, chunk_byte_size) end
    )
    |> Enum.reverse()
  end

  defp build_up_chunk_elements(element, [head | tail], chunk_byte_size) when is_binary(element) do
    if head |> byte_sum >= chunk_byte_size do
      [[element] | [head | tail]]
    else
      [head ++ [element] | tail]
    end
  end
end
