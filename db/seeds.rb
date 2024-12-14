# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Clearing Users and Store Items"

StoreItem.destroy_all

StoreItem.create!(name: 'Teleport', description: 'Instantly teleport to any location on the Grid(Map).', shards_cost: 2, item_id: 1)
StoreItem.create!(name: 'Small Health Potion', description: 'Restores 50% HP', shards_cost: 1, item_id: 2)
StoreItem.create!(name: 'Resurrection Token', description: 'Brings players or other entities back to life', shards_cost: 3, item_id: 3)
StoreItem.create!(name: "Trickster's Relic", description: 'An enchanted artifact that channels chaotic magic, transforming anything it touches into something unpredictable and bizarre.', shards_cost: 10, item_id: 4)
StoreItem.create!(name: 'Emberscale, Fang of the Crimson Wyrm', description: 'A sword with draconic lineage with scales that shimmer with fiery embers.', shards_cost: 5, item_id: 5)
StoreItem.create!(name: "Bloodwood's Whisper", description: 'A beautiful mahogany bow once wielded by the renowned gladiator Bloodwood, famed for felling countless foes with unerring precision. Its craftsmanship surpasses ordinary bows, offering unmatched accuracy and power with every shot.', shards_cost: 5, item_id: 6)
StoreItem.create!(name: 'Hearthsteel', description: "A worn blade with a simple hilt, unassuming at first glance, yet they say the sword still holds the echoes of a kings' discipline and skill, granting its wielder uncanny precision and endurance in battle.", shards_cost: 5, item_id: 7)
StoreItem.create!(name: "Clanbreaker", description: 'A massive, battle-scarred axe with a blade etched in crude but powerful runes. Known for its brutal efficiency and the strength it lent its wielder Ghorak the Unyielding', shards_cost: 5, item_id: 8)
StoreItem.create!(name: 'Grimoire of the Arcane', description: "An old spell book. The pages shift with the reader's will, revealing new secrets as they grow in mastery.", shards_cost: 5, item_id: 9)
StoreItem.create!(name: "Emberbane Wand", description: 'Forged in the heart of a dying volcano, this wand channels the fury of the earth’s molten core. Flames swirl around its iron frame, a reminder of its creation in the fires of ancient, forgotten battles.', shards_cost: 5, item_id: 10)
StoreItem.create!(name: "Frostbite Scepter", description: 'Carved from the heart of a glacial cavern, this wand is crowned with ancient ice crystals that never melt. It draws its power from the frozen depths, capable of summoning blizzards and freezing the very air around its wielder.', shards_cost: 5, item_id: 11)
StoreItem.create!(name: "Aegis of the Arcane Sentinel", description: 'This heavy armor shimmers with ethereal runes that glow faintly in the dark, forged by forgotten mages to protect against both blade and spell.', shards_cost: 5, item_id: 12)
StoreItem.create!(name: "Warbringer's Bulwark", description: "Crafted from the bones of fallen beasts and reinforced with dark iron, this plate armor bears the scars of countless battles.", shards_cost: 5, item_id: 13)
StoreItem.create!(name: "Shadowstalker's Vestments", description: 'Made from the supple hide of a shadowed beast, this lightweight leather armor allows for unparalleled agility and silence.', shards_cost: 5, item_id: 14)
StoreItem.create!(name: "Veil of the Arcane Weaver", description: "This delicate cloth armor is woven from enchanted threads that shimmer with an ethereal glow. Light as a whisper, it offers minimal protection but enhances the wearer's magical abilities", shards_cost: 5, item_id: 15)
StoreItem.create!(name: "Walter", description: "No one really knows what this teddy bear does, but it's definitely something special. Whether it's granting luck, causing random bursts of laughter, or secretly plotting to take over the world, you should use this in a time of need to see.", shards_cost: 10, item_id: 16)

puts "Initialized Store Items!"