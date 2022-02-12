struct BGGUser
    id::Int
    name::String
    country::String
    yearregistered::Int
    lastlogin::Date
end

struct BGGUserReview # review scraped from user page
    id::Int
    name::String
    rating::Float32
    lastmodified::Date
    numplays::Int
    comment::String
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
