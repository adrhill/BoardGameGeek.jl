struct BGGReview # review scraped from game page
    id::Int
    name::String
    username::String
    rating::Float32
    comment::String
end

Base.show(io::IO, r::BGGReview) = print(io, "$(r.rating)/10 for $(r.name) from $(r.username)")

struct BGGGameInfo
    id::Int
    name::String
    mechanics::Vector{String}
    families::Vector{String}
    yearpublished::Int
    minplayers::Int
    maxplayers::Int
    playingtime::Int
    minplaytime::Int
    maxplaytime::Int
    minage::Int
    suggested_numplayers::Dict{String,Tuple{Int64,Int64,Int64}}
    usersrated::Int
    average::Float32
    bayesaverage::Float32
    stddev::Float32
    median::Float32
    owned::Int
    trading::Int
    wanting::Int
    wishing::Int
    numcomments::Int
    numweights::Int
    averageweight::Float32
end

"""
    get_game_reviews(id::Integer; kwargs...)

Scrape all reviews for a game

# Keyword arguments
  - `pagesize::Integer`:
    Number of reviews per page request. Defaults to API maximum 100.
  - `waittime::Real`:
    Wait time between page requests in seconds. Defaults to `2.0f0`.
"""
function get_game_reviews(id::Integer; pagesize::Integer=100, waittime=2.0f0)
    doc = get_xml("$XMLAPI2/thing?id=$(id)&stats=1")
    name = findfirst("/items/item/name[@type='primary']", doc)["value"]
    usersrated = parse(
        Int, findfirst("/items/item/statistics/ratings/usersrated", doc)["value"]
    )
    maxpage = cld(usersrated, pagesize) # using `pagesize` reviews per page
    maxpage == 0 && (maxpage = 1)
    # The actual number of reviews is usually slightly higher than `usersrated`.
    # Count number of reviews on last page to get the real count.
    doc = get_xml(
        "$XMLAPI2/thing?id=$(id)&ratingcomments=1&page=$(maxpage)&pagesize=$(pagesize)"
    )
    review_count =
        (maxpage - 1) * pagesize + length(findall("/items/item/comments/comment", doc))

    if review_count == 0
        return Vector{BGGReview}()
    end

    reviews = Vector{BGGReview}(undef, review_count) # pre-allocate
    @showprogress 1 "Scraping $review_count reviews for $name..." for page in 1:maxpage
        doc = get_xml(
            "$XMLAPI2/thing?id=$(id)&ratingcomments=1&page=$(page)&pagesize=$(pagesize)"
        )
        pagereviews = findall("/items/item/comments/comment", doc)
        for (i, r) in enumerate(pagereviews)
            reviews[(page - 1) * pagesize + i] = BGGReview(
                id, name, r["username"], parse(Float32, r["rating"]), r["value"]
            )
        end
        sleep(waittime)
    end
    return reviews
end

"""
    get_game_info(id::Integer)

Get game information and summary of reviews.
"""
function get_game_info(id::Integer)
    doc = get_xml("$XMLAPI2/thing?id=$(id)&stats=1")
    game = findfirst("/items/item", doc)

    # Primary name of game
    name = findfirst("name[@type='primary']", game)["value"]

    # Parse mechanics and families
    boardgamemechanic = [
        n["value"] for n in findall("link[@type='boardgamemechanic']", game)
    ]
    boardgamefamily = [n["value"] for n in findall("link[@type='boardgamefamily']", game)]

    # Find first index after list of names
    yearpublished = parse(Int, findfirst("yearpublished", game)["value"])
    minplayers = parse(Int, findfirst("minplayers", game)["value"])
    maxplayers = parse(Int, findfirst("maxplayers", game)["value"])

    # Vote counts for player count recommendations
    suggested_numplayers = Dict{String,Tuple{Int64,Int64,Int64}}()
    for res in findall("poll[@name='suggested_numplayers']/results", game)
        numplayers = res["numplayers"]
        suggested_numplayers[numplayers] = tuple(
            parse.(Int, r["numvotes"] for r in elements(res))...
        )
    end

    playingtime = parse(Int, findfirst("playingtime", game)["value"])
    minplaytime = parse(Int, findfirst("minplaytime", game)["value"])
    maxplaytime = parse(Int, findfirst("maxplaytime", game)["value"])
    minage = parse(Int, findfirst("minage", game)["value"])

    # Parse ratings summary
    ratings = findfirst("statistics/ratings", game)
    usersrated = parse(Int, findfirst("usersrated", ratings)["value"])
    average = parse(Float32, findfirst("average", ratings)["value"])
    bayesaverage = parse(Float32, findfirst("bayesaverage", ratings)["value"])
    stddev = parse(Float32, findfirst("stddev", ratings)["value"])
    median = parse(Float32, findfirst("median", ratings)["value"])
    owned = parse(Int, findfirst("owned", ratings)["value"])
    trading = parse(Int, findfirst("trading", ratings)["value"])
    wanting = parse(Int, findfirst("wanting", ratings)["value"])
    wishing = parse(Int, findfirst("wishing", ratings)["value"])
    numcomments = parse(Int, findfirst("numcomments", ratings)["value"])
    numweights = parse(Int, findfirst("numweights", ratings)["value"])
    averageweight = parse(Float32, findfirst("averageweight", ratings)["value"])

    return BGGGameInfo(
        id,
        name,
        boardgamemechanic,
        boardgamefamily,
        yearpublished,
        minplayers,
        maxplayers,
        playingtime,
        minplaytime,
        maxplaytime,
        minage,
        suggested_numplayers,
        usersrated,
        average,
        bayesaverage,
        stddev,
        median,
        owned,
        trading,
        wanting,
        wishing,
        numcomments,
        numweights,
        averageweight,
    )
end
