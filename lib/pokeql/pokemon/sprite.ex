defmodule Pokeql.Pokemon.Sprite do
  @moduledoc """
  Ecto schema for Pokemon sprite images.

  This schema stores the URLs for various Pokemon sprite images including
  front/back views, shiny variants, and gender-specific sprites.
  Each Pokemon has one sprite record containing all image variations.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          front_default: String.t() | nil,
          back_default: String.t() | nil,
          front_shiny: String.t() | nil,
          back_shiny: String.t() | nil,
          front_female: String.t() | nil,
          back_female: String.t() | nil,
          front_shiny_female: String.t() | nil,
          back_shiny_female: String.t() | nil,
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "sprites" do
    field :front_default, :string
    field :back_default, :string
    field :front_shiny, :string
    field :back_shiny, :string
    field :front_female, :string
    field :back_female, :string
    field :front_shiny_female, :string
    field :back_shiny_female, :string

    belongs_to :pokemon, Pokeql.Pokemon

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for sprite data.

  ## Parameters
  - `sprite` - The sprite struct (or %Sprite{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Sprite.changeset(%Sprite{}, %{
      ...>   pokemon_id: 1,
      ...>   front_default: "https://example.com/bulbasaur.png"
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = Sprite.changeset(%Sprite{}, %{front_default: "invalid-url"})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(sprite, attrs) do
    sprite
    |> cast(attrs, [
      :pokemon_id,
      :front_default,
      :back_default,
      :front_shiny,
      :back_shiny,
      :front_female,
      :back_female,
      :front_shiny_female,
      :back_shiny_female
    ])
    |> validate_required([:pokemon_id])
    |> validate_url(:front_default)
    |> validate_url(:back_default)
    |> validate_url(:front_shiny)
    |> validate_url(:back_shiny)
    |> validate_url(:front_female)
    |> validate_url(:back_female)
    |> validate_url(:front_shiny_female)
    |> validate_url(:back_shiny_female)
    |> unique_constraint(:pokemon_id)
    |> foreign_key_constraint(:pokemon_id)
  end

  # Private validation helper
  defp validate_url(changeset, field) do
    case get_change(changeset, field) do
      nil -> changeset
      "" -> changeset
      url ->
        if valid_url?(url) do
          changeset
        else
          add_error(changeset, field, "must be a valid URL")
        end
    end
  end

  defp valid_url?(url) do
    uri = URI.parse(url)
    uri.scheme in ["http", "https"] and not is_nil(uri.host)
  end

  @doc """
  Returns all sprite fields that can contain URLs.
  """
  @spec sprite_fields() :: [atom()]
  def sprite_fields do
    ~w[
      front_default back_default front_shiny back_shiny
      front_female back_female front_shiny_female back_shiny_female
    ]a
  end

  @doc """
  Returns the default sprites (non-shiny, non-gendered).
  """
  @spec default_sprites() :: [atom()]
  def default_sprites do
    ~w[front_default back_default]a
  end

  @doc """
  Returns the shiny variant sprites.
  """
  @spec shiny_sprites() :: [atom()]
  def shiny_sprites do
    ~w[front_shiny back_shiny front_shiny_female back_shiny_female]a
  end

  @doc """
  Returns the female variant sprites.
  """
  @spec female_sprites() :: [atom()]
  def female_sprites do
    ~w[front_female back_female front_shiny_female back_shiny_female]a
  end

  @doc """
  Checks if a sprite has any images available.
  """
  @spec has_images?(t()) :: boolean()
  def has_images?(%__MODULE__{} = sprite) do
    sprite_fields()
    |> Enum.any?(fn field ->
      case Map.get(sprite, field) do
        nil -> false
        "" -> false
        _url -> true
      end
    end)
  end

  @doc """
  Gets the primary sprite URL (front_default if available).
  """
  @spec primary_sprite_url(t()) :: String.t() | nil
  def primary_sprite_url(%__MODULE__{front_default: url}) when is_binary(url) and url != "", do: url
  def primary_sprite_url(%__MODULE__{back_default: url}) when is_binary(url) and url != "", do: url
  def primary_sprite_url(%__MODULE__{front_shiny: url}) when is_binary(url) and url != "", do: url
  def primary_sprite_url(%__MODULE__{}), do: nil
end
