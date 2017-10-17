defmodule Flex.Mapper do
  @moduledoc """
  This module defines a behaviour for mapping your data types to a map for Flex
  
  The simplest way to use this module is to include it as a behaviour and 
  implement the to_doc/1 callback. The module can also be included with use
  and either a flex_fields/1 function must be implemented or fields must be
  passed as an option to `use`.
  
  The functionality to transform the list of fields to a map is delegated to
  Flex.Mapper.Struct.
  
  ## Example
  
    defmodule Book do
      defstruct [:name, :author, :release_year]
      @behaviour Flex.Mapper
      
      def to_doc(book) do
        %{name: book.name, 
          author: book.author,
          year: book.release_year,
          author_bio: author_bio(book)}
      end
      
      defp author_bio(book) do
        AuthorBio.fetch(book.author)
      end
    end
    
    defmodule Book do
      defstruct [:name, :author, :release_year]
      use Flex.Mapper
      
      def flex_fields(book), do: [:name, :author, year: :release_year, :author_bio]
      
      def author_bio(book) do
        AuthorBio.fetch(book.author)
      end
    end
    
    defmodule Book do
      defstruct [:name, :author, :release_year]
      use Flex.Mapper,
        fields: [:name, :author, year: :release_year, :author_bio]
      
      def author_bio(book) do
        AuthorBio.fetch(book.author)
      end
    end
  """
  
  @callback to_doc(any) :: map
  @callback flex_fields(any) :: list
  @optional_callbacks flex_fields: 1
  
  defmacro __using__(opts) do
    quote do
      @behaviour Flex.Mapper
      @flex_fields unquote(opts[:fields])
      
      def flex_fields(_),       do: @flex_fields
      def to_doc(data),         do: to_doc(data, flex_fields(data))
      def to_doc(data, fields), do: Flex.Mapper.Struct.to_doc(data, fields)
      
      defoverridable Flex.Mapper
    end
  end
end

