using BoardGameGeek

id = 75674 # https://boardgamegeek.com/boardgame/75674

game = get_game_info(id)
@test game.name == "Julian: Triumph Before the Storm"
@test game.usersrated > 65

reviews = get_game_reviews(id)
@test length(reviews) == game.usersrated
@test sum(r -> r.rating, reviews) / length(reviews) ≈ game.average
