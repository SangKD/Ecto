#---
# Excerpted from "Programming Ecto",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wmecto for more book information.
#---
##############################################
## Ecto Playground
#
# This script sets up a sandbox for experimenting with Ecto. To
# use it, just add the code you want to try into the Playground.play/0
# function below, then execute the script via mix:
#
#   mix run priv/repo/playground.exs
#
# The return value of the play/0 function will be written to the console
#
# To get the test data back to its original state, just run:
#
#   mix ecto.reset
#
alias MusicDB.Repo
alias MusicDB.{Artist, Album, Track, Genre, Log, AlbumWithEmbeds, ArtistEmbed, TrackEmbed}
alias Ecto.Multi

import Ecto.Query
import Ecto.Changeset

defmodule Playground do
  # this is just to hide the "unused import" warnings while we play
  def this_hides_warnings do
    [Artist, Album, Track, Genre, Repo, Multi, Log, AlbumWithEmbeds, ArtistEmbed, TrackEmbed]
    from(a in "artists")
    from(a in "artists", where: a.id == 1)
    cast({%{}, %{}}, %{}, [])
  end

  def play do
    ###############################################
    #
    # PUT YOUR TEST CODE HERE

    # Look up tracks whose duration > 900 and the respective albums they belong to.
    q = from t in "tracks",
        join: a in "albums", on: t.album_id == a.id,
        where: t.duration > 900,
        select: %{album: a.title, track: t.title}
    Repo.all(q)

    # Look up tracks whose duration > 900, the respective albums they belong to and the artists.
    q = from t in "tracks",
        join: a in "albums", on: t.album_id == a.id,
        join: ar in "artists", on: a.artist_id == ar.id,
        where: t.duration > 900,
        select: %{album: a.title, track: t.title, artist: ar.name}
    Repo.all(q)

    # Look up all the albums by artist Miles Davis
    q = from a in "albums",
        join: ar in "artists", on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis",
        select: [a.title]
    Repo.all(q)

    # Look up the list of tracks by artist Miles Davis
    q = from a in "albums",
        join: ar in "artists", on: a.artist_id == ar.id,
        join: t in "tracks", on: t.album_id == a.id,
        where: ar.name == "Miles Davis",
        select: [t.title]
    Repo.all(q)

    # Composing the above query
    albums_by_miles = from a in "albums", as: :albums,
      join: ar in "artists", as: :artists,
      on: a.artist_id == ar.id,
      where: ar.name == "Miles Davis"

    album_query = from [artists: ar, albums: a] in albums_by_miles,
      select: [a.title, ar.name]
    Repo.all(album_query)

    # Reuse the albums_by_miles query to get the tracks.
    track_query = from [albums: a] in albums_by_miles,
      join: t in "tracks", on: a.id == t.album_id,
      select: t.title
    Repo.all(track_query)

    # Check if a given query has a named binding
    has_named_binding?(albums_by_miles, :albums)

    # Composing queries with functions
    # Ecto has the ability to make queries from composable functions.
    # This makes the query fragments reusable, and substantially improves readability.
    # def albums_by_artist(artist_name) do
    #   from a in "albums",
    #     join: ar in "artists", on: a.artist_id == ar.id,
    #     where: ar.name == ^artist_name
    # end

    # # albums_by_bobby = albums_by_artist("Bobby Hutcherson")

    # def by_artist(query, artist_name) do
    #   from a in query,
    #     join: ar in "artists", on: a.artist_id == ar.id,
    #     where: ar.name == ^artist_name
    # end

    # # albums_by_bobby = by_artist("albums", "Bobby Hutcherson")

    # def with_tracks_longer_than(query, duration) do
    #   from a in query,
    #     join: t in "tracks", on: t.album_id == a.id,
    #     where: t.duration > ^query,
    #     distinct: true

    # end

    # def title_only(query) do
    #   from a in query, select: a.title
    # end

    # q =
    #   "albums"
    #   |> by_artist("Miles Davis")
    #   |> with_tracks_longer_than(720)
    #   |> title_only()

    # Repo.all(q)

    # Combining queries using or_where
    albums_by_miles = from a in "albums",
      join: ar in "artists", on: a.artist_id == ar.id,
      where: ar.name == "Miles Davis"

    q = from [a, ar] in albums_by_miles,
      where: ar.name == "Bobby Hutcherson",
      select: a.title
    Repo.to_sql(:all, q)

    # q = from a in "albums",
    #   join: ar in "artists", on: a.artist_id == ar.id,
    #   where: ar.name == "Miles Davis" or ar.name == "Bobby Hutcherson",
    #   select: %{artist: ar.name, album: a.title}

    q = from [a, ar] in albums_by_miles,
      or_where: ar.name == "Bobby Hutcherson",
      select: %{artist: ar.name, album: a.title}

    Repo.all(q)
    #
    ##############################################

  end

end

# add your test code to Playground.play above - this will execute it
# and write the result to the console
IO.inspect(Playground.play())
