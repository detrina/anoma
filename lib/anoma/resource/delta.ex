defmodule Anoma.Resource.Delta do
  import Noun

  # usually non_neg_integer, but not in execution
  @type t() :: %{binary() => integer()}

  @spec add(t(), t()) :: t()
  def add(d1, d2) do
    Map.merge(d1, d2, fn _k, v1, v2 -> v1 + v2 end)
    |> Map.reject(fn {_k, v} -> v == 0 end)
  end

  @spec negate(t()) :: t()
  def negate(r) do
    Map.new(r, fn {k, v} -> {k, -v} end)
  end

  @spec sub(t(), t()) :: t()
  def sub(d1, d2) do
    add(d1, negate(d2))
  end

  # use nock map once it exists
  @spec to_noun(t()) :: Noun.t()
  def to_noun(delta = %{}) do
    for {k, v} <- delta do
      if v >= 0 do
        [k, 0 | v]
      else
        [k, 1 | -v]
      end
    end ++ 0
  end

  @spec from_noun(Noun.t()) :: t()
  def from_noun(delta_nock) do
    delta_list = list_nock_to_erlang(delta_nock)

    for [k, v_sign | v_value] <- delta_list, into: %{} do
      binary_k = atom_integer_to_binary(k)

      if v_sign == 0 do
        {binary_k, v_value}
      else
        {binary_k, -v_value}
      end
    end
  end
end
