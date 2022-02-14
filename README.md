# BoardGameGeek.jl

| **Documentation**                                                     | **Build Status**                                      |
|:----------------------------------------------------------------------|:------------------------------------------------------|
| [![][docs-stab-img]][docs-stab-url] [![][docs-dev-img]][docs-dev-url] | [![][ci-img]][ci-url] [![][codecov-img]][codecov-url] |

Utilities to scrape [BoardGameGeek.com](https://boardgamegeek.com), the IMDB of board games.

## Installation
To install this package, open the Julia package manager by typing `]` in the REPL and run 
```julia-repl
pkg> add BoardGameGeek
```
BoardGameGeek.jl is compatible with all Julia versions ⩾ `1.0`.

## Quick tour
Start by importing this package and [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl):
```julia
using BoardGameGeek
using DataFrames
```

We can query the reviews a specific user wrote via `userreviews(username)`
```julia
julia> user = "bggjulia"

julia> DataFrame(userreviews(user))
4×5 DataFrame
 Row │ id      name                       username  rating   comment 
     │ Int64   String                     String    Float32  String  
─────┼───────────────────────────────────────────────────────────────
   1 │ 140934  Arboretum                  bggjulia      9.0
   2 │ 225694  Decrypto                   bggjulia      8.5
   3 │    188  Go                         bggjulia     10.0
   4 │ 256960  Pax Pamir: Second Edition  bggjulia      9.0
```

or simply use `collection` get the game IDs of his collection
```julia
julia> collection(user)
4-element Vector{Int64}:
 140934
 225694
    188
 256960
```

### Game reviews
Use `gamereviews(id)` to scrape all reviews that were written for a specific game
```julia
julia> DataFrame(gamereviews(188))
Scraping 15700 reviews for Go... 100%|█████████████████████| Time: 0:06:31
15700×5 DataFrame
   Row │ id     name    username          rating   comment                       ⋯
       │ Int64  String  String            Float32  String                        ⋯
───────┼──────────────────────────────────────────────────────────────────────────
     1 │   188  Go      xenocles             10.0  My all time favourite 'classi ⋯
     2 │   188  Go      guus                 10.0  The mother of all strategy ga
     3 │   188  Go      Varthlokkur          10.0
     4 │   188  Go      Hiroshi Ishikawa     10.0  Simple rule yet extremely dee
     5 │   188  Go      layotte              10.0                                ⋯
   ⋮   │   ⋮      ⋮            ⋮             ⋮                     ⋮             ⋱
 15696 │   188  Go      aircastle             1.0
 15697 │   188  Go      ashleybobal53         1.0
 15698 │   188  Go      danperrault           1.0
 15699 │   188  Go      vikings40             1.0                                ⋯
 15700 │   188  Go      akaiready             1.0
                                                   1 column and 15690 rows omitted
```
Note that this can take a while for games with many reviews, as we don't want to run into the BoardGameGeek API rate limit. 
The default wait time of 2 seconds per 100 reviews can be changed via the keyword argument `waittime`.



### Full game info
Use `gameinfo(id)` to obtain all sorts of information about a game. 
Refer to the reference below for a summary of all data.
```julia
julia> DataFrame(gameinfo(collection(user)))
4×24 DataFrame
 Row │ id      name                       yearpublished  minplayers  maxplayers  ⋯
     │ Int64   String                     Int64          Int64       Int64       ⋯
─────┼────────────────────────────────────────────────────────────────────────────
   1 │ 140934  Arboretum                           2015           2           4  ⋯
   2 │ 225694  Decrypto                            2018           3           8
   3 │    188  Go                                 -2200           2           2
   4 │ 256960  Pax Pamir: Second Edition           2019           1           5
                                                                19 columns omitted
```

### GeekBuddies
Finally, we can also take a look at "GeekBuddies" and user profiles via `userinfo(name)`: 
```julia
julia> buddies(user)
2-element Vector{String}:
 "Aldie"
 "dakarp"

julia> DataFrame(userinfo(buddies(user)))
2×5 DataFrame
 Row │ id     name    country        yearregistered  lastlogin  
     │ Int64  String  String         Int64           Date       
─────┼──────────────────────────────────────────────────────────
   1 │   688  Aldie   United States            1999  2022-02-13
   2 │   792  dakarp  United States            2002  2022-02-13
```

## Reference
### Exported functions
|                       | Description                                       |
|:----------------------|:--------------------------------------------------|
| `gamereviews(id)`     | return all ratings & reviews written about a game |
| `gameinfo(id)`        | return basic information about a game             |
| `userreviews(name)`   | return all reviews written by a user              |
| `userinfo(name)`      | return basic user information                     |
| `buddies(name)`       | return usernames of a user's friends              |
| `collection(name)`    | return game IDs of a user's collection            | 

### Data types
Fields of a `BGGGameInfo` object returned by `gameinfo(id)`:
```
id                   :: Int64
name                 :: String
yearpublished        :: Int64
minplayers           :: Int64
maxplayers           :: Int64
playingtime          :: Int64
minplaytime          :: Int64
maxplaytime          :: Int64
minage               :: Int64
usersrated           :: Int64
average              :: Float32
bayesaverage         :: Float32
stddev               :: Float32
median               :: Float32
owned                :: Int64
trading              :: Int64
wanting              :: Int64
wishing              :: Int64
numcomments          :: Int64
numweights           :: Int64
averageweight        :: Float32
mechanics            :: Vector{String}
families             :: Vector{String}
suggested_numplayers :: Dict{String, Tuple{Int64, Int64, Int64}}
```

[docs-stab-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stab-url]: https://adrhill.github.io/BoardGameGeek.jl/stable

[docs-dev-img]: https://img.shields.io/badge/docs-main-blue.svg
[docs-dev-url]: https://adrhill.github.io/BoardGameGeek.jl/dev

[ci-img]: https://github.com/adrhill/BoardGameGeek.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/adrhill/BoardGameGeek.jl/actions

[codecov-img]: https://codecov.io/gh/adrhill/BoardGameGeek.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/adrhill/BoardGameGeek.jl
