struct BGGUser
    id::Int
    name::String
    country::String
    yearregistered::Int
    lastlogin::Date
end

"""
    userinfo(name::String)
    userinfo(names::AbstractArray{<:String})

Get user from name string.
"""
function userinfo(name::AbstractString; waittime=0.0f0)
    doc = get_xml("$XMLAPI2/user?name=$(name)")
    id = parse(Int, findfirst("/user", doc)["id"])
    name = findfirst("/user", doc)["name"]
    yearregistered = parse(Int, findfirst("/user/yearregistered", doc)["value"])
    lastlogin = Date(findfirst("/user/lastlogin", doc)["value"])
    country = findfirst("/user/country", doc)["value"]

    sleep(waittime)
    return BGGUser(id, name, country, yearregistered, lastlogin)
end

function userinfo(names::AbstractArray{<:String}; waittime=2.0f0) # add waittime by default
    usercount = length(names)
    users = Vector{BGGUser}(undef, usercount) # pre-allocate
    @showprogress 1 "Scraping $usercount user profiles..." for (i, n) in enumerate(names)
        users[i] = userinfo(n; waittime=waittime)
    end
    return users
end

"""
    buddies(name::String)
    buddies(names::AbstractArray{<:String})
    buddies(user::BGGUser)

Return list of user names of buddies of a user.
"""
function buddies(name::String; waittime=0.0f0)
    doc = get_xml("$XMLAPI2/user?name=$(name)&buddies=1")

    sleep(waittime)
    return [b["name"] for b in findall("/user/buddies/buddy", doc)]
end

function buddies(names::AbstractArray{<:String}; waittime=2.0f0) # add waittime by default
    return [buddies(n; waittime=waittime) for n in names]
end

buddies(user::BGGUser) = buddies(user.name)

"""
    userreviews(name::String)
    userreviews(names::AbstractArray{<:String})
    userreviews(user::BGGUser)

Return list of all board game reviews a user wrote (ignoring expansions).
"""
function userreviews(name::String; waittime=0.0f0)
    doc = get_xml(
        "$(XMLAPI2)/collection?username=$(name)&rated=1&stats=1&excludesubtype=boardgameexpansion",
    )
    games = findall("/items/item", doc)

    sleep(waittime)
    return _parse_review_from_collection.(games, name)
end

function userreviews(names::AbstractArray{<:String}; waittime=2.0f0) # add waittime by default
    return collect(Iterators.flatten(userreviews(n; waittime=waittime) for n in names))
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

"""
    collection(name::String)
    collection(user::BGGUser)

Return game ids in collection of user.
"""
collection(name::String) = getproperty.(userreviews(name), :id)
collection(user::BGGUser) = collection(user.name)
