class Game < ApplicationRecord
  belongs_to :current_turn_user, class_name: "User", foreign_key: "current_turn_user_id", optional: true
  belongs_to :owner, class_name: "User", foreign_key: "owner_id", optional: true

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
  has_many :tiles, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :join_code,
            format: {
              with: /\A[A-Z0-9]{6}\z/,
              message: "must be 6 uppercase alphanumeric characters"
            },
            uniqueness: true,
            presence: true
  validates :map_size, presence: true
  validate :validate_map_size_format_and_minimum

  # Callbacks

  after_validation :normalize_join_code
  after_create :set_default_quests
  after_create -> { generate_tiles(map_size: map_size) }
l
  def non_owner_players_count
    game_users.where.not(user_id: owner_id).count
  end

  private

  def normalize_join_code
    self.join_code = join_code.upcase.strip if join_code.present?
  end

  def validate_map_size_format_and_minimum
    return if map_size.blank?

    unless map_size.match?(/^\d+x\d+$/)
      errors.add(:map_size, "must be in the format 'NxM' (e.g., '6x6')")
      return
    end

    rows, columns = map_size.split("x").map(&:to_i)
    if rows < 6 || columns < 6
      errors.add(:map_size, "must be at least 6x6")
    end
  end

  TILE_TYPES = {
    "grassland" => [
      "A serene expanse of green with scattered wildflowers.",
      "A lone shepherd watching over a flock of sheep.",
      "Gently sloping hills with patches of rich, golden wheat.",
      "A dirt path winding its way to a distant, bustling market town.",
      "A quiet pond reflecting the blue sky, surrounded by cattails.",
      "Ruins of an old stone bridge now home to nesting birds.",
      "A small, lively village with smoke rising from chimneys.",
      "Grazing wild horses, their tails flicking in the summer breeze.",
      "A single oak tree offering shade to travelers.",
      "Remnants of an ancient battlefield with weathered stone markers.",
      "A wandering bard singing songs of old by a campfire.",
      "A hidden entrance to a dungeon overgrown with vines and moss."
    ],
    "lake" => [
      "A crystal-clear body of water with fish darting just beneath the surface.",
      "A secluded beach lined with smooth, rounded stones.",
      "A family of ducks paddling near the reeds.",
      "A small fishing boat tied to an aging wooden dock.",
      "A distant castle reflected perfectly in the still waters.",
      "A bustling trade village by the shore, filled with fishermen and merchants.",
      "A small island at the lake's center, shrouded in mist.",
      "A partially sunken ruin peeking out of the water.",
      "A peaceful campsite with logs arranged around a firepit near the shore.",
      "An enchanted glow coming from beneath the water's depths.",
      "A forgotten shrine surrounded by lilies, half-submerged in the lake.",
      "An old hermit's shack, precariously built on stilts."
    ],
    "tundra" => [
      "An endless, icy plain broken only by sparse patches of grass.",
      "A frozen stream winding its way through the barren landscape.",
      "A solitary cabin, smoke billowing from its chimney.",
      "A herd of caribou grazing on the sparse tundra vegetation.",
      "A nomadic camp made of animal hides, pitched against the wind.",
      "A lone wolf stalking its prey across the snow.",
      "A cave opening rimmed with icicles.",
      "A mysterious stone pillar, weathered by years of harsh frost.",
      "An abandoned sled half-buried in the snow.",
      "A hot spring steaming in the frigid air.",
      "A small cluster of evergreen trees offering brief shelter.",
      "Tracks in the snow leading to an unknown destination."
    ],
    "mountains" => [
      "Towering peaks with snow cascading down their sides.",
      "A small mining town clinging to the edge of a cliff.",
      "A rugged trail zigzagging through jagged rock formations.",
      "An ancient fortress built into the mountain face.",
      "A roaring waterfall cascading into a hidden valley below.",
      "A solitary eagle circling high above the peaks.",
      "A mysterious cave mouth with carvings etched around its entrance.",
      "A weathered shrine to the gods of the mountain.",
      "A narrow pass between towering cliffs, leading to unknown lands.",
      "A village of stone huts nestled in a high-altitude meadow.",
      "A dangerous crevasse, its depths hidden by swirling mist.",
      "A collapsed mine entrance littered with broken tools."
    ],
    "foothills" => [
      "Gently rolling hills leading up to towering mountains.",
      "A quiet farmstead with fields of barley swaying in the wind.",
      "A winding river cutting its way through the foothills.",
      "A caravan resting at a crossroads near the base of the hills.",
      "A crumbling tower offering a vantage point over the valley.",
      "A dense patch of forest stretching up the hills.",
      "A village built into the hillside with terraced gardens.",
      "A hidden cave with faint markings above its entrance.",
      "A field of wildflowers blanketing the hillside.",
      "A hunter's camp with fresh game hanging from a rack.",
      "An old stone road snaking through the hills, leading to distant lands.",
      "A mysterious ruin overrun by moss and creeping vines."
    ],
    "desert" => [
      "Endless dunes stretching into the horizon.",
      "A cluster of cacti standing tall against the scorching sun.",
      "A small oasis surrounded by date palms.",
      "The ruins of an ancient city half-buried in the sand.",
      "A nomadic camp with brightly colored tents.",
      "A lone camel drinking from a cracked, clay water trough.",
      "A rocky outcrop providing shade from the relentless sun.",
      "A hidden cave with cool, refreshing air spilling out.",
      "Tracks in the sand leading to a caravan on the move.",
      "A sandstorm brewing in the distance, obscuring the sky.",
      "A merchant's wagon laden with exotic goods parked at a trade post.",
      "The skeleton of a long-forgotten beast, bleached by the sun."
    ],
    "forest" => [
      "Towering trees with a dense canopy that blocks out the sunlight.",
      "A quiet glade with a crystal-clear stream winding through it.",
      "A network of animal trails crisscrossing the forest floor.",
      "A hidden cabin nestled among the trees, almost invisible.",
      "A large, ancient tree with carvings etched into its bark.",
      "A bandit camp hidden deep within the forest.",
      "A forest village with wooden houses perched in the treetops.",
      "The sound of distant wolves howling in the night.",
      "A ruined temple, its stones covered in moss and vines.",
      "A witch's hut surrounded by strange herbs and glowing mushrooms.",
      "A grove of sacred trees, marked with mystical symbols.",
      "A dense thicket of brambles, nearly impassable."
    ],
    "hold_capital" => [
      "A sprawling city with towering stone walls, bustling streets, and grand architecture.",
      "A magnificent city dominated by a castle perched on a hill, overlooking the surrounding lands.",
      "The capital city boasts lavish gardens surrounding a grand palace where the king resides.",
      "A vast city marketplace, alive with merchants, goods, and lively chatter echoing through the streets.",
      "The heart of the city is marked by a council hall and an imposing throne room, symbolizing power.",
      "Massive city gates adorned with golden insignias stand as the pride of the kingdom's capital.",
      "A cathedral rises above the city skyline, its towering spires visible for miles.",
      "The bustling harbor of the capital city is filled with ships from distant lands, bringing wealth and culture.",
      "The royal quarters gleam with marble and jewels, a beacon in the center of the city's grandeur.",
      "The city's sprawling districts are home to traders, artisans, and noble estates, forming a vibrant capital.",
      "The capital city is fortified with military barracks and training grounds filled with disciplined soldiers.",
      "An ancient hall of records sits at the city's core, chronicling the kingdom's long and storied history."
    ]
  }

  def generate_tiles(map_size: self.map_size)
    weighted_tile_types = [
      "grassland", "grassland", "grassland", "grassland", "grassland",
      "lake", "lake", "lake", "lake",
      "tundra", "tundra", "tundra",
      "mountains", "mountains", "mountains",
      "foothills", "foothills", "foothills",
      "desert", "desert", "desert",
      "forest", "forest", "forest", "forest",
      "hold_capital" # Fewer entries for lower probability
    ]

    rows, columns = map_size.split("x").map(&:to_i)
    (0...rows).each do |y|
      (0...columns).each do |x|
        tile_type = weighted_tile_types.sample
        description = TILE_TYPES[tile_type].sample

        tiles.create!(
          x_coordinate: x,
          y_coordinate: y,
          tile_type: tile_type,
          image_reference: description
        )
      end
    end
  end


  def set_default_quests
    default_quests = [
      {"quest_type":1, "refresh_times":1, "condition":3, "reward":3, "progress":0},
      {"quest_type":2, "refresh_times":1, "condition":1, "reward":5, "progress":0},
      {"quest_type":3, "refresh_times":1, "condition":1, "reward":10, "progress":0}
    ]
    update!(quests: default_quests.to_json) unless self.quests.present?
  end

end