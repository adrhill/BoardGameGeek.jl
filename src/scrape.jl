using HTTP, EzXML, Dates, ProgressMeter

const XMLAPI2 = "https://boardgamegeek.com/xmlapi2"

struct BGGUser
    id::Int
    name::String
    country::String
    yearregistered::Int
    lastlogin::Date
end
BGGUser(name::String) = get_user(name)

function get_xml(url::AbstractString; sleep_on_fail=5)
    url = replace(url, " " => "%20")
    r = HTTP.request("GET", url)
    xmldoc = parsexml(String(r.body))
    return root(xmldoc)
end

"""
    get_user(name)

Get user from name string.
"""
function get_user(name::AbstractString)
    doc = get_xml("$XMLAPI2/user?name=$(name)")
    id = parse(Int, findfirst("/user", doc)["id"])
    name = findfirst("/user", doc)["name"]
    yearregistered = parse(Int, findfirst("/user/yearregistered", doc)["value"])
    lastlogin = Date(findfirst("/user/lastlogin", doc)["value"])
    country = findfirst("/user/country", doc)["value"]
    return BGGUser(id, name, country, yearregistered, lastlogin)
end

"""
    get_buddies(name)
    get_buddies(user::BGGUser)

Return list of user names of buddies of a user.
"""
function get_buddies(name::String)
    doc = get_xml("$XMLAPI2/user?name=$(name)&buddies=1")
    return [b["name"] for b in findall("/user/buddies/buddy", doc)]
end
get_buddies(user::BGGUser) = get_buddies(user.name)

"""
    get_user_reviews(name)
    get_user_reviews(user::BGGUser)

Return list of board game reviews a user wrote (ignoring expansions).
"""
function get_user_reviews(name::String)
    doc = get_xml(
        "$(XMLAPI2)/collection?username=$(name)&rated=1&stats=1&excludesubtype=boardgameexpansion",
    )
    games = findall("/items/item", doc)
    return _parse_review_from_collection.(games)
end
get_user_reviews(user::BGGUser) = get_user_reviews(user.name)

struct BGGUserReview # review scraped from user page
    id::Int
    name::String
    rating::Float32
    lastmodified::Date
    numplays::Int
    comment::String
end

function _parse_review_from_collection(n::EzXML.Node)
    id = parse(Int, n["objectid"])

    name = findfirst("name", n).content
    rating = parse(Float32, findfirst("stats/rating", n)["value"])
    lastmodified = Date(findfirst("status", n)["lastmodified"][1:10])
    numplays = parse(Int, findfirst("numplays", n).content)
    _comment = findfirst("comment", n)
    comment = ""
    if !isnothing(_comment)
        comment = _comment.content
    end
    return BGGUserReview(id, name, rating, lastmodified, numplays, comment)
end

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

struct BGGReview # review scraped from game page
    id::Int
    name::String
    username::String
    rating::Float32
    comment::String
end

function get_game_reviews(id::Integer; waittime=2, pagesize=100)
    doc = get_xml("$XMLAPI2/thing?id=$(id)&stats=1")
    name = findfirst("/items/item/name[@type='primary']", doc)["value"]
    usersrated = parse(
        Int, findfirst("/items/item/statistics/ratings/usersrated", doc)["value"]
    )
    maxpage = cld(usersrated, pagesize) # using `pagesize` reviews per page

    # The actual number of reviews is usually slightly higher than `usersrated`.
    # Count number of reviews on last page to get the real count.
    doc = get_xml("$XMLAPI2/thing?id=$(id)&ratingcomments=1&page=$(maxpage)&pagesize=$(pagesize)")
    review_count = (maxpage-1)*pagesize + length(findall("/items/item/comments/comment", doc))

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
