# BoardGameGeek.jl

| **Documentation**                                                     | **Build Status**                                      |
|:----------------------------------------------------------------------|:------------------------------------------------------|
| [![][docs-stab-img]][docs-stab-url] [![][docs-dev-img]][docs-dev-url] | [![][ci-img]][ci-url] [![][codecov-img]][codecov-url] |

Utilities to scrape [BoardGameGeek.com](https://boardgamegeek.com), the IMDB of board games.

## Installation
To install this package and its dependencies, open the Julia REPL and run 
```julia-repl
julia> ]add https://github.com/adrhill/BoardGameGeek.jl
```
The package is compatible with all Julia versions starting at `1.0`.

## Example
```julia-repl
julia> userreviews("bggjulia")
4-element Vector{BoardGameGeek.BGGReview}:
 9.0/10 for Arboretum from bggjulia
 8.5/10 for Decrypto from bggjulia
 10.0/10 for Go from bggjulia
 9.0/10 for Pax Pamir: Second Edition from bggjulia
```

## Quick reference
### Exported functions
|                       | Description                                       |
|:----------------------|:--------------------------------------------------|
| `gamereviews(id)`     | return all ratings & reviews written about a game |
| `gameinfo(id)`        | return basic information about a game             |
| `userreviews(name)`   | return all reviews written by a user              |
| `userinfo(name)`      | return basic user information                     |
| `buddies(name)`       | return usernames of a user's friends              |


### Data types
`BGGReview`
```
id       :: Int64
name     :: String
username :: String
rating   :: Float32
comment  :: String
```

`BGGUser`
```
id             :: Int64
name           :: String
country        :: String
yearregistered :: Int64
lastlogin      :: Date
```

`BGGGameInfo`
```
id                   :: Int64
name                 :: String
mechanics            :: Vector{String}
families             :: Vector{String}
yearpublished        :: Int64
minplayers           :: Int64
maxplayers           :: Int64
playingtime          :: Int64
minplaytime          :: Int64
maxplaytime          :: Int64
minage               :: Int64
suggested_numplayers :: Dict{String, Tuple{Int64, Int64, Int64}}
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
```

[docs-stab-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stab-url]: https://adrhill.github.io/BoardGameGeek.jl/stable

[docs-dev-img]: https://img.shields.io/badge/docs-main-blue.svg
[docs-dev-url]: https://adrhill.github.io/BoardGameGeek.jl/dev

[ci-img]: https://github.com/adrhill/BoardGameGeek.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/adrhill/BoardGameGeek.jl/actions

[codecov-img]: https://codecov.io/gh/adrhill/BoardGameGeek.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/adrhill/BoardGameGeek.jl
