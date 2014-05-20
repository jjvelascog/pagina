# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

BodegasVecinas.find_or_create_by(username: "grupo6", password: "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9")
BodegasVecinas.find_or_create_by(username: "grupo3", password: "05452d511826a15ba32d6fc4f3562ea75b16db8f")