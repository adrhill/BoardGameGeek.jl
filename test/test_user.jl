using BoardGameGeek
using Dates

name = "bggjulia"

user = userinfo(name)
@test user.id == 3162756
@test user.name == name
@test user.country == "Poland"
@test user.yearregistered == 2022

reviews = userreviews(name)
@test length(reviews) == 4

r = first(sort(reviews; by=r -> -r.rating))
@test r.id == 188
@test r.name == "Go"
@test r.username == "bggjulia"
@test r.rating == 10.0
@test r.comment == ""
