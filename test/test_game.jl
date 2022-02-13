using BoardGameGeek

id = 75674 # https://boardgamegeek.com/boardgame/75674

game = gameinfo(id)
@test game.name == "Julian: Triumph Before the Storm"
@test game.usersrated > 65

reviews = gamereviews(id)
@test length(reviews) == game.usersrated
@test sum(r -> r.rating, reviews) / length(reviews) ≈ game.average

reviews2 = gamereviews(id; waittime=2.5, pagesize=50)
@test reviews2 == reviews
