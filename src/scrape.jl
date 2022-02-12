using HTTP, EzXML, Dates

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
    user = get_xml("https://api.geekdo.com/xmlapi2/user?name=$(name)")
    id = parse(Int, user["id"])
    name = user["name"]
    attr = elements(user)
    yearregistered = parse(Int, attr[4]["value"])
    lastlogin = Date(attr[5]["value"])
    country = attr[7]["value"]
    return BGGUser(id, name, country, yearregistered, lastlogin)
end

"""
    get_buddies(name)
    get_buddies(user::BGGUser)

Return list of user names of buddies of a user.
"""
function get_buddies(name::String)
    user = get_xml("https://api.geekdo.com/xmlapi2/user?name=$(name)&buddies=1")
    buddies = user.lastelement
    names = [b["name"] for b in elements(buddies)]
    return names
end
get_buddies(user::BGGUser) = get_buddies(user.name)

"""
    get_user_reviews(name)
    get_user_reviews(user::BGGUser)

Return list of board game reviews a user wrote (ignoring expansions).
"""
function get_user_reviews(name::String)
    collection = get_xml(
        "https://api.geekdo.com/xmlapi2/collection?username=$(name)&rated=1&stats=1&excludesubtype=boardgameexpansion",
    )
    return _parse_review_from_collection.(elements(collection))
end
get_user_reviews(user::BGGUser) = get_user_reviews(user.name)

struct BGGFullReview # review scraped from user page
    id::Int
    name::String
    rating::Float32
    lastmodified::Date
    numplays::Int
    comment::String
end

function _parse_review_from_collection(n::EzXML.Node)
    id = parse(Int, n["objectid"])
    attr = elements(n)
    name = attr[1].content
    rating = parse(Float32, attr[5].firstelement["value"])
    lastmodified = Date(attr[6]["lastmodified"][1:10])
    numplays = parse(Int, attr[7].content)
    if length(attr) > 7 && attr[8].name == "comment"
        comment = attr[8].content
    else
        comment = ""
    end
    return BGGReview(id, name, rating, lastmodified, numplays, comment)
end

struct BGGGameInfo
    yearpublished::Int
    minplayers::Int
    maxplayers::Int
    playingtime::Int
    minplaytime::Int
    maxplaytime::Int
    minage::Int
    name::String
    suggested_numplayers::Vector{Tuple{Int64,Int64,Int64}}
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
    mechanics::Vector{String}
    families::Vector{String}
end

function get_game_info(id::Integer)
    game = get_xml("https://boardgamegeek.com/xmlapi2/thing?id=$(id)&stats=1").firstelement
    attr = elements(game)
    # Find primary name
    name = filter(n -> (n.name == "name" && n["type"] == "primary"), attr)[1]["value"]

    # Find first index after list of names
    i = findfirst(n -> n.name == "yearpublished", attr)
    yearpublished = parse(Int, attr[i]["value"])
    minplayers = parse(Int, attr[i + 1]["value"])
    maxplayers = parse(Int, attr[i + 2]["value"])

    # Vote counts for player count recommendations
    suggested_numplayers = map(elements(attr[i + 3])) do playercountrecs
        recs = elements(playercountrecs)
        # Best / Recommended / Not Recommended
        return parse.(Int, (recs[1]["numvotes"], recs[2]["numvotes"], recs[3]["numvotes"]))
    end

    playingtime = parse(Int, attr[i + 4]["value"])
    minplaytime = parse(Int, attr[i + 5]["value"])
    maxplaytime = parse(Int, attr[i + 6]["value"])
    minage = parse(Int, attr[i + 7]["value"])

    # Parse ratings summary
    ratings = elements(attr[end].firstelement)
    usersrated = parse(Int, ratings[1]["value"])
    average = parse(Float32, ratings[2]["value"])
    bayesaverage = parse(Float32, ratings[3]["value"])
    stddev = parse(Float32, ratings[5]["value"])
    median = parse(Float32, ratings[6]["value"])
    owned = parse(Int, ratings[7]["value"])
    trading = parse(Int, ratings[8]["value"])
    wanting = parse(Int, ratings[9]["value"])
    wishing = parse(Int, ratings[10]["value"])
    numcomments = parse(Int, ratings[11]["value"])
    numweights = parse(Int, ratings[12]["value"])
    averageweight = parse(Float32, ratings[13]["value"])

    # Game mechanics
    mechattr = filter(n -> (n.name == "link" && n["type"] == "boardgamemechanic"), attr)
    mechanics = [n["value"] for n in mechattr]

    # Game families
    famattr = filter(n -> (n.name == "link" && n["type"] == "boardgamefamily"), attr)
    families = [n["value"] for n in famattr]

    return BGGGameInfo(
        yearpublished,
        minplayers,
        maxplayers,
        playingtime,
        minplaytime,
        maxplaytime,
        minage,
        name,
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
        mechanics,
        families,
    )
end

struct BGGShortReview # review scraped from game page
    id::Int
    username::String
    rating::Float32
    comment::String
end

function _node2shortreview(id, n::EzXML.Node)
    return BGGShortReview(id, n["username"], parse(Float32, n["rating"]), n["value"])
end

function get_game_reviews(id::Integer; waittime=1.5)
    all_reviews = Vector{BGGShortReview}()
    page = 1
    while true
        url = "https://boardgamegeek.com/xmlapi2/thing?id=$(id)&ratingcomments=1&page=$(page)&pagesize=100"
        game = get_xml(url).firstelement
        reviews = elements(game.lastelement)
        append!(all_reviews, map(r -> _node2shortreview(id, r), reviews))
        length(reviews) != 100 && break # last page
        page += 1
        sleep(waittime)
    end
    return all_reviews
end
