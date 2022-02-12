using BoardGameGeek
using Dates

name = "bggjulia"

user = get_user(name)
@test user.id == 3162756
@test user.name == name
@test user.country == "Poland"
@test user.yearregistered == 2022

reviews = get_user_reviews(name)
r = first(reviews)
@test length(reviews) == 1
@test r.id == 188
@test r.name == "Go"
@test r.rating == 10.0
@test r.lastmodified == Date("2022-02-12")
@test r.numplays == 0
@test r.comment == ""
