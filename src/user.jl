struct BGGUser
    id::Int
    name::String
    country::String
    yearregistered::Int
    lastlogin::Date
end

"""
    userinfo(name::String)

Get user from name string.
"""
function userinfo(name::AbstractString)
    doc = get_xml("$XMLAPI2/user?name=$(name)")
    id = parse(Int, findfirst("/user", doc)["id"])
    name = findfirst("/user", doc)["name"]
    yearregistered = parse(Int, findfirst("/user/yearregistered", doc)["value"])
    lastlogin = Date(findfirst("/user/lastlogin", doc)["value"])
    country = findfirst("/user/country", doc)["value"]
    return BGGUser(id, name, country, yearregistered, lastlogin)
end

"""
    buddies(name::String)
    buddies(user::BGGUser)

Return list of user names of buddies of a user.
"""
function buddies(name::String)
    doc = get_xml("$XMLAPI2/user?name=$(name)&buddies=1")
    return [b["name"] for b in findall("/user/buddies/buddy", doc)]
end
buddies(user::BGGUser) = buddies(user.name)

"""
    userreviews(name::String)
    userreviews(user::BGGUser)

Return list of all board game reviews a user wrote (ignoring expansions).
"""
function userreviews(name::String)
    doc = get_xml(
        "$(XMLAPI2)/collection?username=$(name)&rated=1&stats=1&excludesubtype=boardgameexpansion",
    )
    games = findall("/items/item", doc)
    return _parse_review_from_collection.(games, name)
end
userreviews(user::BGGUser) = userreviews(user.name)

function _parse_review_from_collection(n::EzXML.Node, username)
    id = parse(Int, n["objectid"])

    gamename = findfirst("name", n).content
    rating = parse(Float32, findfirst("stats/rating", n)["value"])
    _comment = findfirst("comment", n)
    comment = ""
    if !isnothing(_comment)
        comment = _comment.content
    end
    return BGGReview(id, gamename, username, rating, comment)
end
