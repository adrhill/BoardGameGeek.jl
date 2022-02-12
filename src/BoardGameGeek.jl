module BoardGameGeek

using HTTP
using EzXML
using Dates: Date
using ProgressMeter: @showprogress

# Using the BGG XML API2
# Reference: https://boardgamegeek.com/wiki/page/BGG_XML_API2
const XMLAPI2 = "https://boardgamegeek.com/xmlapi2"

include("utils.jl")
include("game.jl")
include("user.jl")

export BGGUser
export get_user, get_buddies, get_user_reviews
export get_game_info, get_game_reviews

end # module
