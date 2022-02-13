module BoardGameGeek

using HTTP
using EzXML
using Dates: Date
using ProgressMeter: @showprogress
import Base: show

# Using the BGG XML API2
# Reference: https://boardgamegeek.com/wiki/page/BGG_XML_API2
const XMLAPI2 = "https://boardgamegeek.com/xmlapi2"

include("compat.jl")
include("utils.jl")
include("game.jl")
include("user.jl")

export BGGUser
export userinfo, userreviews, buddies
export gameinfo, gamereviews

end # module
