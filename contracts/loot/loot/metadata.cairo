// amarna: disable=arithmetic-add,arithmetic-div,arithmetic-mul,arithmetic-sub
// -----------------------------------
//   loot.loot.Uri Library
//   Builds a JSON array which to represent Loot metadata
//
// MIT License
// -----------------------------------

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_unsigned_div_rem
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le

from contracts.loot.constants.adventurer import AdventurerState, AdventurerStatic
from contracts.loot.adventurer.interface import IAdventurer
from contracts.loot.constants.item import (
    Item, 
    ItemIds,
    Slot,
    Type, 
    Material,
    ItemNamePrefixes, 
    ItemNameSuffixes, 
    ItemSuffixes
)
from contracts.settling_game.utils.game_structs import ExternalContractIds

from contracts.loot.loot.ILoot import ILoot

namespace LootUriUtils {
    namespace Symbols {
        const LeftBracket = 123;
        const RightBracket = 125;
        const InvertedCommas = 34;
        const Comma = 44;
    }

    namespace TraitKeys {
        const Slot = '{"trait_type":"Slot",';
        const Type = '{"trait_type":"Type",';
        const Material = '{"trait_type":"Material",';
        const Rank = '{"trait_type":"Rank",';
        const Greatness = '{"trait_type":"Greatness",';
        const CreatedBlock = '{"trait_type":"Created Block",';
        const XP = '{"trait_type":"XP",';
        const Adventurer = '{"trait_type":"Adventurer",';
        const Bag = '{"trait_type":"Bag",';
        const ValueKey = '"value":"';
    }

    namespace ItemNames {
        const Pendant = 'Pendant';
        const Necklace = 'Necklace';
        const Amulet = 'Amulet';
        const SilverRing = 'Silver Ring';
        const BronzeRing = 'Bronze Ring';
        const PlatinumRing = 'Platinum Ring';
        const TitaniumRing = 'Titanium Ring';
        const GoldRing = 'Gold Ring';
        const GhostWand = 'Ghost Wand';
        const GraveWand = 'Grave Wand';
        const BoneWand = 'Bone Wand';
        const Wand = 'Wand';
        const Grimoire = 'Grimoire';
        const Chronicle = 'Chronicle';
        const Tome = 'Tome';
        const Book = 'Book';
        const Katana = 'Katana';
        const Falchion = 'Falchion';
        const Scimitar = 'Scimitar';
        const LongSword = 'Long Sword';
        const ShortSword = 'Short Sword';
        const Warhammer = 'Warhammer';
        const Quarterstaff = 'Quarterstaff';
        const Maul = 'Maul';
        const Mace = 'Mace';
        const Club = 'Club';
        const DivineRobe = 'Divine Robe';
        const SilkRobe = 'Silk Robe';
        const LinenRobe = 'Linen Robe';
        const Robe = 'Robe';
        const Shirt = 'Shirt';
        const DemonHusk = 'Demon Husk';
        const DragonskinArmor = 'Dragonskin Armor';
        const StuddedLeatherArmor = 'Studded Leather Armor';
        const HardLeatherArmor = 'Hard Leather Armor';
        const LeatherArmor = 'Leather Armor';
        const HolyChestplate = 'Holy Chestplate';
        const OrnateChestplate = 'Ornate ChestPlate';
        const PlateMail = 'Plate Mail';
        const ChainMail = 'Chain Mail';
        const RingMail = 'Ring Mail';
        const Crown = 'Crown';
        const DivineHood = 'Divine Hood';
        const SilkHood = 'Silk Hood';
        const LinenHood = 'Linen Hood';
        const Hood = 'Hood';
        const DemonCrown = 'Demon Crown';
        const DragonsCrown = 'Dragons Crown';
        const WarCap = 'War Cap';
        const LeatherCap = 'Leather Cap';
        const Cap = 'Cap';
        const AncientHelm = 'Ancient Helm';
        const OrnateHelm = 'Ornate Helm';
        const GreatHelm = 'Great Helm';
        const FullHelm = 'Full Helm';
        const Helm = 'Helm';
        const BrightsilkSash = 'Brightsilk Sash';
        const SilkSash = 'Silk Sash';
        const WoolSash = 'Wool Sash';
        const LinenSash = 'Linen Sash';
        const Sash = 'Sash';
        const DemonhideBelt = 'Demonhide Belt';
        const DragonskinBelt = 'Dragonskin Belt';
        const StuddedLeatherBelt = 'Studded Leather Belt';
        const HardLeatherBelt = 'Hard Leather Belt';
        const LeatherBelt = 'Leather Belt';
        const OrnateBelt = 'Ornate Belt';
        const WarBelt = 'War Belt';
        const PlatedBelt = 'Plated Belt';
        const MeshBelt = 'Mesh Belt';
        const HeavyBelt = 'Heavy Belt';
        const DivineSlippers = 'Divine Slippers';
        const SilkSlippers = 'Silk Slippers';
        const WoolShoes = 'Wool Shoes';
        const LinenShoes = 'Linen Shoes';
        const Shoes = 'Shoes';
        const DemonhideBoots = 'Demonhide Boots';
        const DragonskinBoots = 'Dragonskin Boots';
        const StuddedLeatherBoots = 'Studded Leather Boots';
        const HardLeatherBoots = 'Hard Leather Boots';
        const LeatherBoots = 'Leather Boots';
        const ChainBoots = 'Chain Boots';
        const HeavyBoots = 'Heavy Boots';
        const HolyGauntlets = 'Holy Gauntlets';
        const OrnateGauntlets = 'Ornate Gauntlets';
        const Gauntlets = 'Gauntlets';
        const DivineGloves = 'Divine Gloves';
        const SilkGloves = 'Silk Gloves';
        const WoolGloves = 'Wool Gloves';
        const LinenGloves = 'Linen Gloves';
        const Gloves = 'Gloves';
        const DemonsHands = 'Demons Hands';
        const DragonskinGloves = 'Dragonskin Gloves';
        const StuddedLeatherGloves = 'Studded Leather Gloves';
        const HardLeatherGloves = 'Hard Leather Gloves';
        const LeatherGloves = 'Leather Gloves';
        const HolyGreaves = 'Holy Greaves';
        const OrnateGreaves = 'Ornate Greaves';
        const Greaves = 'Greaves';
        const ChainGloves = 'Chain Gloves';
        const HeavyGloves = 'Heavy Gloves';
    }

    namespace ItemNamePrefixes {
        const Agony = 'Agony ';
        const Apocalypse = 'Apocalypse ';
        const Armageddon = 'Armageddon ';
        const Beast = 'Beast ';
        const Behemoth = 'Behemoth ';
        const Blight = 'Blight ';
        const Blood = 'Blood ';
        const Bramble = 'Bramble ';
        const Brimstone = 'Brimstone ';
        const Brood = 'Brood ';
        const Carrion = 'Carrion ';
        const Cataclysm = 'Cataclysm ';
        const Chimeric = 'Chimeric ';
        const Corpse = 'Corpse ';
        const Corruption = 'Corruption ';
        const Damnation = 'Damnation ';
        const Death = 'Death ';
        const Demon = 'Demon ';
        const Dire = 'Dire ';
        const Dragon = 'Dragon ';
        const Dread = 'Dread ';
        const Doom = 'Doom ';
        const Dusk = 'Dusk ';
        const Eagle = 'Eagle ';
        const Empyrean = 'Empyrean ';
        const Fate = 'Fate ';
        const Foe = 'Foe ';
        const Gale = 'Gale ';
        const Ghoul = 'Ghoul ';
        const Gloom = 'Gloom ';
        const Glyph = 'Glyph ';
        const Golem = 'Golem ';
        const Grim = 'Grim ';
        const Hate = 'Hate ';
        const Havoc = 'Havoc ';
        const Honour = 'Honour ';
        const Horror = 'Horror ';
        const Hypnotic = 'Hypnotic ';
        const Kraken = 'Kraken ';
        const Loath = 'Loath ';
        const Maelstrom = 'Maelstrom ';
        const Mind = 'Mind ';
        const Miracle = 'Miracle ';
        const Morbid = 'Morbid ';
        const Oblivion = 'Oblivion ';
        const Onslaught = 'Onslaught ';
        const Pain = 'Pain ';
        const Pandemonium = 'Pandemonium ';
        const Phoenix = 'Phoenix ';
        const Plague = 'Plague ';
        const Rage = 'Rage ';
        const Rapture = 'Rapture ';
        const Rune = 'Rune ';
        const Skull = 'Skull ';
        const Sol = 'Sol ';
        const Soul = 'Soul ';
        const Sorrow = 'Sorrow ';
        const Spirit = 'Spirit ';
        const Storm = 'Storm ';
        const Tempest = 'Tempest ';
        const Torment = 'Torment ';
        const Vengeance = 'Vengeance ';
        const Victory = 'Victory ';
        const Viper = 'Viper ';
        const Vortex = 'Vortex ';
        const Woe = 'Woe ';
        const Wrath = 'Wrath ';
        const Lights = 'Lights ';
        const Shimmering = 'Shimmering ';
    }

    namespace ItemNameSuffixes {
        const Bane = 'Bane ';
        const Root = 'Root ';
        const Bite = 'Bite ';
        const Song = 'Song ';
        const Roar = 'Roar ';
        const Grasp = 'Grasp ';
        const Instrument = 'Instrument ';
        const Glow = 'Glow ';
        const Bender = 'Bender ';
        const Shadow = 'Shadow ';
        const Whisper = 'Whisper ';
        const Shout = 'Shout ';
        const Growl = 'Growl ';
        const Tear = 'Tear ';
        const Peak = 'Peak ';
        const Form = 'Form ';
        const Sun = 'Sun ';
        const Moon = 'Moon ';
    }

    namespace ItemSuffixes{
        const of_Power = ' Of Power';
        const of_Giant = ' Of Giant';
        const of_Titans = ' Of Titans';
        const of_Skill = ' Of Skill';
        const of_Perfection = ' Of Perfection';
        const of_Brilliance = ' Of Brilliance';
        const of_Enlightenment = ' Of Enlightenment';
        const of_Protection = ' Of Protection';
        const of_Anger = ' Of Anger';
        const of_Rage = ' Of Rage';
        const of_Fury = ' Of Fury';
        const of_Vitriol = ' Of Vitriol';
        const of_the_Fox = ' Of The Fox';
        const of_Detection = ' Of Detection';
        const of_Reflection = ' Of Reflection';
        const of_the_Twins = ' Of The Twins';
    }

    namespace Slots {
        const Weapon = 'Weapon';
        const Chest = 'Chest';
        const Head = 'Head';
        const Waist = 'Waist';
        const Feet = 'Feet';
        const Hands = 'Hands';
        const Neck = 'Neck';
        const Ring = 'Ring';
    }

    namespace Types {
        const Generic = 'Generic';
        const WeaponGeneric = 'Generic Weapon';
        const WeaponBludgeon = 'Bludgeon Weapon';
        const WeaponBlade = 'Blade Weapon';
        const WeaponMagic = 'Magic Weapon';
        const ArmorGeneric = 'Generic Armor';
        const ArmorMetal = 'Metal Armor';
        const ArmorHide = 'Hide Armor';
        const ArmorCloth = 'Cloth Armor';
        const Ring = 'Ring';
        const Necklace = 'Necklace';
    }

    namespace Materials {
        const Generic = 'Generic';
        const MetalGeneric = 'Generic Metal';
        const MetalAncient = 'Ancient Metal';
        const MetalHoly = 'Holy Metal';
        const MetalOrnate = 'Ornate Metal';
        const MetalGold = 'Gold Metal';
        const MetalSilver = 'Silver Metal';
        const MetalBronze = 'Bronze Metal';
        const MetalPlatinum = 'Platinum Metal';
        const MetalTitanium = 'Titanium Metal';
        const MetalSteel = 'Steel Metal';
        const ClothGeneric = 'Generic Cloth';
        const ClothRoyal = 'Royal Cloth';
        const ClothDivine = 'Divine Cloth';
        const ClothBrightsilk = 'Brightsilk Cloth';
        const ClothSilk = 'Silk Cloth';
        const ClothWool = 'Wool Cloth';
        const ClothLinen = 'Linen Cloth';
        const BioticGeneric = 'Generic Biotic';
        const BioticDemonGeneric = 'Generic Demon Biotic';
        const BioticDemonBlood = 'Blood Demon Biotic';
        const BioticDemonBones = 'Bones Demon Biotic';
        const BioticDemonBrain = 'Brain Demon Biotic';
        const BioticDemonEyes = 'Eyes Demon Biotic';
        const BioticDemonHide = 'Hide Demon Biotic';
        const BioticDemonFlesh = 'Flesh Demon Biotic';
        const BioticDemonHair = 'Hair Demon Biotic';
        const BioticDemonHeart = 'Heart Demon Biotic';
        const BioticDemonEntrails = 'Entrails Demon Biotic';
        const BioticDemonHands = 'Hands Demon Biotic';
        const BioticDemonFeet = 'Feet Demon Biotic';
        const BioticDragonGeneric = 'Generic Dragon Biotic';
        const BioticDragonBlood = 'Blood Dragon Biotic';
        const BioticDragonBones = 'Bones Dragon Biotic';
        const BioticDragonBrain = 'Brain Dragon Biotic';
        const BioticDragonEyes = 'Eyes Dragon Biotic';
        const BioticDragonSkin = 'Skin Dragon Biotic';
        const BioticDragonFlesh = 'Flesh Dragon Biotic';
        const BioticDragonHair = 'Hair Dragon Biotic';
        const BioticDragonHeart = 'Heart Dragon Biotic';
        const BioticDragonEntrails = 'Entrails Dragon Biotic';
        const BioticDragonHands = 'Hands Dragon Biotic';
        const BioticDragonFeet = 'Feet Dragon Biotic';
        const BioticAnimalGeneric = 'Generic Animal Biotic';
        const BioticAnimalBlood = 'Blood Animal Biotic';
        const BioticAnimalBones = 'Bones Animal Biotic';
        const BioticAnimalBrain = 'Brain Animal Biotic';
        const BioticAnimalEyes = 'Eyes Animal Biotic';
        const BioticAnimalHide = 'Hide Animal Biotic';
        const BioticAnimalFlesh = 'Flesh Animal Biotic';
        const BioticAnimalHair = 'Hair Animal Biotic';
        const BioticAnimalHeart = 'Heart Animal Biotic';
        const BioticAnimalEntrails = 'Entrails Animal Biotic';
        const BioticAnimalHands = 'Hands Animal Biotic';
        const BioticAnimalFeet = 'Feet Animal Biotic';
        const BioticHumanGeneric = 'Generic Human Biotic';
        const BioticHumanBlood = 'Blood Human Biotic';
        const BioticHumanBones = 'Bones Human Biotic';
        const BioticHumanBrain = 'Brain Human Biotic';
        const BioticHumanEyes = 'Eyes Human Biotic';
        const BioticHumanHide = 'Hide Human Biotic';
        const BioticHumanFlesh = 'Flesh Human Biotic';
        const BioticHumanHair = 'Hair Human Biotic';
        const BioticHumanHeart = 'Heart Human Biotic';
        const BioticHumanEntrails = 'Entrails Human Biotic';
        const BioticHumanHands = 'Hands Human Biotic';
        const BioticHumanFeet = 'Feet Human Biotic';
        const PaperGeneric = 'Generic Paper';
        const PaperMagical = 'Magical Paper';
        const WoodGeneric = 'Generic Wood';
        const WoodHardGeneric = 'Generic Hard Wood';
        const WoodHardWalnut = 'Walnut Hard Wood';
        const WoodHardMahogany = 'Mahogany Hard Wood';
        const WoodHardMaple = 'Maple Hard Wood';
        const WoodHardOak = 'Oak Hard Wood';
        const WoodHardRosewood = 'Rosewood Hard Wood';
        const WoodHardCherry = 'Cherry Hard Wood';
        const WoodHardBalsa = 'Balsa Hard Wood';
        const WoodHardBirch = 'Birch Hard Wood';
        const WoodHardHolly = 'Holly Hard Wood';
        const WoodSoftGeneric = 'Generic Soft Wood';
        const WoodSoftCedar = 'Cedar Soft Wood';
        const WoodSoftPine = 'Pine Soft Wood';
        const WoodSoftFir = 'Fir Soft Wood';
        const WoodSoftHemlock = 'Hemlock Soft Wood';
        const WoodSoftSpruce = 'Spruce Soft Wood';
        const WoodSoftElder = 'Elder Soft Wood';
        const WoodSoftYew = 'Yew Soft Wood';
    }
}

namespace LootUri {
    // @notice build uri array from stored item data
    // @implicit range_check_ptr
    // @param item_id: id of the item
    // @param item_data: unpacked data for item
    func build{syscall_ptr: felt*, range_check_ptr}(
        item_id: Uint256, item_data: Item, adventurer_address: felt
    ) -> (encoded_len: felt, encoded: felt*) {
        alloc_locals;

        // pre-defined for reusability
        let left_bracket = LootUriUtils.Symbols.LeftBracket;
        let right_bracket = LootUriUtils.Symbols.RightBracket;
        let inverted_commas = LootUriUtils.Symbols.InvertedCommas;
        let comma = LootUriUtils.Symbols.Comma;

        let data_format = 'data:application/json,';

        // keys
        let description_key = '"description":';
        let name_key = '"name":';
        let image_key = '"image":';
        let attributes_key = '"attributes":';

        let left_square_bracket = 91;
        let right_square_bracket = 93;

        // get value of description
        let description_value = '"Loot"';

        // adventurer image url values
        let image_url_1 = 'https://d23fdhqc1jb9no';
        let image_url_2 = '.cloudfront.net/Item/';

        let (values: felt*) = alloc();
        assert values[0] = data_format;
        assert values[1] = left_bracket;  // start
        // description key
        assert values[2] = description_key;
        assert values[3] = description_value;
        assert values[4] = comma;
        // name value
        assert values[5] = name_key;
        assert values[6] = inverted_commas;

        let (name_prefix_index) = append_item_name_prefix(item_data.Prefix_1, 7, values);
        let (name_suffix_index) = append_item_name_suffix(item_data.Prefix_2, name_prefix_index, values);
        let (name_index) =  append_item_name(item_data.Id, name_suffix_index, values);
        let (suffix_index) = append_item_suffix(item_data.Suffix, name_index, values);
        let (greatness_suffix_index) = append_item_greatness_suffix(item_data.Greatness, suffix_index, values);

        assert values[greatness_suffix_index] = inverted_commas;
        assert values[greatness_suffix_index + 1] = comma;
        // image value
        assert values[greatness_suffix_index + 2] = image_key;
        assert values[greatness_suffix_index + 3] = inverted_commas;
        assert values[greatness_suffix_index + 4] = image_url_1;
        assert values[greatness_suffix_index + 5] = image_url_2;
        let (id_size) = append_felt_ascii(item_data.Id, values + greatness_suffix_index + 6);
        let id_index = greatness_suffix_index + 6 + id_size;
        assert values[id_index] = '.webp';
        assert values[id_index + 1] = inverted_commas;
        assert values[id_index + 2] = comma;
        assert values[id_index + 3] = attributes_key;
        assert values[id_index + 4] = left_square_bracket;
        // slot

        let (slot_index) = append_slot(item_data.Slot, id_index + 5, values);

        // type

        let (type_index) = append_type(item_data.Type, slot_index, values);

        // material
        assert values[type_index] = LootUriUtils.TraitKeys.Material;
        assert values[type_index + 1] = LootUriUtils.TraitKeys.ValueKey;

        let (material_index) = append_material(item_data.Material, type_index + 2, values);
        
        assert values[material_index] = inverted_commas;
        assert values[material_index + 1] = right_bracket;
        assert values[material_index + 2] = comma;

        // rank
        assert values[material_index + 3] = LootUriUtils.TraitKeys.Rank;
        assert values[material_index + 4] = LootUriUtils.TraitKeys.ValueKey;
        assert values[material_index + 5] = item_data.Rank + 48;
        assert values[material_index + 6] = inverted_commas;
        assert values[material_index + 7] = right_bracket;
        assert values[material_index + 8] = comma;
        // greatness
        assert values[material_index + 9] = LootUriUtils.TraitKeys.Greatness;
        assert values[material_index + 10] = LootUriUtils.TraitKeys.ValueKey;

        let (greatness_size) = append_felt_ascii(item_data.Greatness, values + material_index + 11);
        let greatness_index = material_index + 11 + greatness_size;

        assert values[greatness_index] = inverted_commas;
        assert values[greatness_index + 1] = right_bracket;
        assert values[greatness_index + 2] = comma;
        // created
        assert values[greatness_index + 3] = LootUriUtils.TraitKeys.CreatedBlock;
        assert values[greatness_index + 4] = LootUriUtils.TraitKeys.ValueKey;

        let (created_size) = append_felt_ascii(item_data.CreatedBlock, values + greatness_index + 5);
        let created_index = greatness_index + 5 + created_size;
       
        assert values[created_index] = inverted_commas;
        assert values[created_index + 1] = right_bracket;
        assert values[created_index + 2] = comma;
        // XP
        assert values[created_index + 3] = LootUriUtils.TraitKeys.XP;
        assert values[created_index + 4] = LootUriUtils.TraitKeys.ValueKey;

        let (xp_size) = append_felt_ascii(item_data.XP, values + created_index + 5);
        let xp_index = created_index + 5 + xp_size;
        
        assert values[xp_index] = inverted_commas;
        assert values[xp_index + 1] = right_bracket;
        assert values[xp_index + 2] = comma;
        // adventurer
        assert values[xp_index + 3] = LootUriUtils.TraitKeys.Adventurer;
        assert values[xp_index + 4] = LootUriUtils.TraitKeys.ValueKey;

        let (adventurer) = IAdventurer.get_adventurer_by_id(adventurer_address, Uint256(item_data.Adventurer, 0));
        assert values[xp_index + 5] = adventurer.Name;
        
        assert values[xp_index + 6] = inverted_commas;
        assert values[xp_index + 7] = right_bracket;
        assert values[xp_index + 8] = comma;
        // bag
        assert values[xp_index + 9] = LootUriUtils.TraitKeys.Bag;
        assert values[xp_index + 10] = LootUriUtils.TraitKeys.ValueKey;

        let (bag_size) = append_felt_ascii(item_data.Bag, values + xp_index + 11);
        let bag_index = xp_index + 11 + bag_size;
        
        assert values[bag_index] = inverted_commas;
        assert values[bag_index + 1] = right_bracket;
        assert values[bag_index + 2] = comma;

        assert values[bag_index + 3] = right_square_bracket;
        assert values[bag_index + 4] = right_bracket;

        return (encoded_len=bag_index + 5, encoded=values);
    }

    // @notice append felts to uri array for item name prefix
    // @implicit range_check_ptr
    // @param name_prefix_id: id of the name prefix, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_item_name_prefix{range_check_ptr}(name_prefix_id: felt, values_index: felt, values: felt*) -> (
        name_prefix_index: felt
    ) {
        if (name_prefix_id == 0) {
            return (values_index,);
        }
        if (name_prefix_id == ItemNamePrefixes.Agony) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Agony;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Apocalypse) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Apocalypse;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Armageddon) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Armageddon;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Beast) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Beast;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Behemoth) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Behemoth;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Blight) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Blight;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Blood) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Blood;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Bramble) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Bramble;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Brimstone) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Brimstone;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Brood) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Brood;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Carrion) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Carrion;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Cataclysm) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Cataclysm;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Chimeric) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Chimeric;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Corpse) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Corpse;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Corruption) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Corruption;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Damnation) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Damnation;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Death) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Death;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Demon) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Demon;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Dire) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Dire;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Dragon) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Dragon;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Dread) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Dread;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Doom) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Doom;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Dusk) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Dusk;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Eagle) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Eagle;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Empyrean) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Empyrean;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Fate) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Fate;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Foe) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Foe;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Gale) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Gale;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Ghoul) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Ghoul;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Gloom) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Gloom;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Glyph) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Glyph;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Golem) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Golem;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Grim) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Grim;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Hate) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Hate;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Havoc) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Havoc;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Honour) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Honour;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Horror) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Horror;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Hypnotic) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Hypnotic;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Kraken) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Kraken;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Loath) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Loath;
            return (values_index + 1,);
        }
         if (name_prefix_id == ItemNamePrefixes.Maelstrom) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Maelstrom;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Mind) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Mind;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Miracle) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Miracle;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Morbid) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Morbid;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Oblivion) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Oblivion;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Onslaught) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Onslaught;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Pain) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Pain;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Pandemonium) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Pandemonium;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Phoenix) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Phoenix;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Plague) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Plague;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Rage) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Rage;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Rapture) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Rapture;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Rune) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Rune;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Skull) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Skull;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Sol) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Sol;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Soul) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Soul;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Sorrow) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Sorrow;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Spirit) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Spirit;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Storm) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Storm;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Tempest) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Tempest;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Torment) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Torment;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Vengeance) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Vengeance;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Victory) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Victory;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Viper) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Viper;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Vortex) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Vortex;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Woe) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Woe;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Wrath) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Wrath;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Lights) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Lights;
            return (values_index + 1,);
        }
        if (name_prefix_id == ItemNamePrefixes.Shimmering) {
            assert values[values_index] = LootUriUtils.ItemNamePrefixes.Shimmering;
            return (values_index + 1,);
        }
        return (values_index,);
    }

    // @notice append felts to uri array for item name suffix
    // @implicit range_check_ptr
    // @param name_suffix_id: id of the name suffix, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_item_name_suffix{range_check_ptr}(name_suffix_id: felt, values_index: felt, values: felt*) -> (
        name_suffix_index: felt
    ) {
        if (name_suffix_id == 0) {
            return (values_index,);
        }
        if (name_suffix_id == ItemNameSuffixes.Bane) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Bane;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Root) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Root;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Bite) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Bite;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Song) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Song;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Roar) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Roar;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Grasp) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Grasp;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Instrument) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Instrument;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Glow) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Glow;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Bender) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Bender;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Shadow) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Shadow;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Whisper) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Whisper;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Shout) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Shout;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Growl) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Growl;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Tear) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Tear;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Peak) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Peak;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Form) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Form;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Sun) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Sun;
            return (values_index + 1,);
        }
        if (name_suffix_id == ItemNameSuffixes.Moon) {
            assert values[values_index] = LootUriUtils.ItemNameSuffixes.Moon;
            return (values_index + 1,);
        }
        return (values_index,);
    }

    // @notice append felts to uri array for item name
    // @implicit range_check_ptr
    // @param name_id: id of the name, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_item_name{range_check_ptr}(name_id: felt, values_index: felt, values: felt*) -> (
        name_index: felt
    ) {
        if (name_id == 0) {
            return (values_index,);
        }
        if (name_id == ItemIds.Pendant) {
            assert values[values_index] = LootUriUtils.ItemNames.Pendant;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Necklace) {
            assert values[values_index] = LootUriUtils.ItemNames.Necklace;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Amulet) {
            assert values[values_index] = LootUriUtils.ItemNames.Amulet;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilverRing) {
            assert values[values_index] = LootUriUtils.ItemNames.SilverRing;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.BronzeRing) {
            assert values[values_index] = LootUriUtils.ItemNames.BronzeRing;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.PlatinumRing) {
            assert values[values_index] = LootUriUtils.ItemNames.PlatinumRing;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.TitaniumRing) {
            assert values[values_index] = LootUriUtils.ItemNames.TitaniumRing;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.GoldRing) {
            assert values[values_index] = LootUriUtils.ItemNames.GoldRing;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.GhostWand) {
            assert values[values_index] = LootUriUtils.ItemNames.GhostWand;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.GraveWand) {
            assert values[values_index] = LootUriUtils.ItemNames.GraveWand;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.BoneWand) {
            assert values[values_index] = LootUriUtils.ItemNames.BoneWand;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Wand) {
            assert values[values_index] = LootUriUtils.ItemNames.Wand;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Grimoire) {
            assert values[values_index] = LootUriUtils.ItemNames.Grimoire;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Chronicle) {
            assert values[values_index] = LootUriUtils.ItemNames.Chronicle;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Tome) {
            assert values[values_index] = LootUriUtils.ItemNames.Tome;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Book) {
            assert values[values_index] = LootUriUtils.ItemNames.Book;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Katana) {
            assert values[values_index] = LootUriUtils.ItemNames.Katana;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Falchion) {
            assert values[values_index] = LootUriUtils.ItemNames.Falchion;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Scimitar) {
            assert values[values_index] = LootUriUtils.ItemNames.Scimitar;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LongSword) {
            assert values[values_index] = LootUriUtils.ItemNames.LongSword;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.ShortSword) {
            assert values[values_index] = LootUriUtils.ItemNames.ShortSword;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Warhammer) {
            assert values[values_index] = LootUriUtils.ItemNames.Warhammer;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Quarterstaff) {
            assert values[values_index] = LootUriUtils.ItemNames.Quarterstaff;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Maul) {
            assert values[values_index] = LootUriUtils.ItemNames.Maul;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Mace) {
            assert values[values_index] = LootUriUtils.ItemNames.Mace;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Club) {
            assert values[values_index] = LootUriUtils.ItemNames.Club;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DivineRobe) {
            assert values[values_index] = LootUriUtils.ItemNames.DivineRobe;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilkRobe) {
            assert values[values_index] = LootUriUtils.ItemNames.SilkRobe;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LinenRobe) {
            assert values[values_index] = LootUriUtils.ItemNames.LinenRobe;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Robe) {
            assert values[values_index] = LootUriUtils.ItemNames.Robe;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DemonHusk) {
            assert values[values_index] = LootUriUtils.ItemNames.DemonHusk;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DragonskinArmor) {
            assert values[values_index] = LootUriUtils.ItemNames.DragonskinArmor;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.StuddedLeatherArmor) {
            assert values[values_index] = LootUriUtils.ItemNames.StuddedLeatherArmor;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HardLeatherArmor) {
            assert values[values_index] = LootUriUtils.ItemNames.HardLeatherArmor;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LeatherArmor) {
            assert values[values_index] = LootUriUtils.ItemNames.LeatherArmor;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HolyChestplate) {
            assert values[values_index] = LootUriUtils.ItemNames.HolyChestplate;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.OrnateChestplate) {
            assert values[values_index] = LootUriUtils.ItemNames.OrnateChestplate;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.PlateMail) {
            assert values[values_index] = LootUriUtils.ItemNames.PlateMail;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.ChainMail) {
            assert values[values_index] = LootUriUtils.ItemNames.ChainMail;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.RingMail) {
            assert values[values_index] = LootUriUtils.ItemNames.RingMail;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Crown) {
            assert values[values_index] = LootUriUtils.ItemNames.Crown;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DivineHood) {
            assert values[values_index] = LootUriUtils.ItemNames.DivineHood;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilkHood) {
            assert values[values_index] = LootUriUtils.ItemNames.SilkHood;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LinenHood) {
            assert values[values_index] = LootUriUtils.ItemNames.LinenHood;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Hood) {
            assert values[values_index] = LootUriUtils.ItemNames.Hood;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DemonCrown) {
            assert values[values_index] = LootUriUtils.ItemNames.DemonCrown;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DragonsCrown) {
            assert values[values_index] = LootUriUtils.ItemNames.DragonsCrown;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.WarCap) {
            assert values[values_index] = LootUriUtils.ItemNames.WarCap;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LeatherCap) {
            assert values[values_index] = LootUriUtils.ItemNames.LeatherCap;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Cap) {
            assert values[values_index] = LootUriUtils.ItemNames.Cap;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.AncientHelm) {
            assert values[values_index] = LootUriUtils.ItemNames.AncientHelm;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.OrnateHelm) {
            assert values[values_index] = LootUriUtils.ItemNames.OrnateHelm;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.GreatHelm) {
            assert values[values_index] = LootUriUtils.ItemNames.GreatHelm;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.FullHelm) {
            assert values[values_index] = LootUriUtils.ItemNames.FullHelm;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Helm) {
            assert values[values_index] = LootUriUtils.ItemNames.Helm;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.BrightsilkSash) {
            assert values[values_index] = LootUriUtils.ItemNames.BrightsilkSash;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilkSash) {
            assert values[values_index] = LootUriUtils.ItemNames.SilkSash;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.WoolSash) {
            assert values[values_index] = LootUriUtils.ItemNames.WoolSash;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LinenSash) {
            assert values[values_index] = LootUriUtils.ItemNames.LinenSash;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Sash) {
            assert values[values_index] = LootUriUtils.ItemNames.Sash;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DemonhideBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.DemonhideBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DragonskinBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.DragonskinBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.StuddedLeatherBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.StuddedLeatherBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HardLeatherBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.HardLeatherBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LeatherBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.LeatherBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.OrnateBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.OrnateBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.WarBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.WarBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.PlatedBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.PlatedBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.MeshBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.MeshBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HeavyBelt) {
            assert values[values_index] = LootUriUtils.ItemNames.HeavyBelt;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DivineSlippers) {
            assert values[values_index] = LootUriUtils.ItemNames.DivineSlippers;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilkSlippers) {
            assert values[values_index] = LootUriUtils.ItemNames.SilkSlippers;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.WoolShoes) {
            assert values[values_index] = LootUriUtils.ItemNames.WoolShoes;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LinenShoes) {
            assert values[values_index] = LootUriUtils.ItemNames.LinenShoes;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Shoes) {
            assert values[values_index] = LootUriUtils.ItemNames.Shoes;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DemonhideBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.DemonhideBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DragonskinBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.DragonskinBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.StuddedLeatherBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.StuddedLeatherBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HardLeatherBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.HardLeatherBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LeatherBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.LeatherBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.ChainBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.ChainBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HeavyBoots) {
            assert values[values_index] = LootUriUtils.ItemNames.HeavyBoots;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HolyGauntlets) {
            assert values[values_index] = LootUriUtils.ItemNames.HolyGauntlets;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.OrnateGauntlets) {
            assert values[values_index] = LootUriUtils.ItemNames.OrnateGauntlets;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Gauntlets) {
            assert values[values_index] = LootUriUtils.ItemNames.Gauntlets;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DivineGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.DivineGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.SilkGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.SilkGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.WoolGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.WoolGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LinenGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.LinenGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Gloves) {
            assert values[values_index] = LootUriUtils.ItemNames.Gloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DemonsHands) {
            assert values[values_index] = LootUriUtils.ItemNames.DemonsHands;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.DragonskinGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.DragonskinGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.StuddedLeatherGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.StuddedLeatherGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HardLeatherGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.HardLeatherGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.LeatherGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.LeatherGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HolyGreaves) {
            assert values[values_index] = LootUriUtils.ItemNames.HolyGreaves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.OrnateGreaves) {
            assert values[values_index] = LootUriUtils.ItemNames.OrnateGreaves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.Greaves) {
            assert values[values_index] = LootUriUtils.ItemNames.Greaves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.ChainGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.ChainGloves;
            return (values_index + 1,);
        }
        if (name_id == ItemIds.HeavyGloves) {
            assert values[values_index] = LootUriUtils.ItemNames.HeavyGloves;
            return (values_index + 1,);
        }
        return (values_index,);
    }

    // @notice append felts to uri array for item suffix
    // @implicit range_check_ptr
    // @param suffix_id: id of the suffix, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_item_suffix{range_check_ptr}(suffix_id: felt, values_index: felt, values: felt*) -> (
        suffix_index: felt
    ) {
        if (suffix_id == 0) {
            return (values_index,);
        }
        if (suffix_id == ItemSuffixes.of_Power) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Power;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Giant) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Giant;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Titans) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Titans;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Skill) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Skill;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Perfection) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Perfection;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Brilliance) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Brilliance;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Enlightenment) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Enlightenment;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Protection) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Protection;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Anger) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Anger;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Rage) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Rage;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Fury) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Fury;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Vitriol) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Vitriol;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_the_Fox) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_the_Fox;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Detection) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Detection;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_Reflection) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_Reflection;
            return (values_index + 1,);
        }
        if (suffix_id == ItemSuffixes.of_the_Twins) {
            assert values[values_index] = LootUriUtils.ItemSuffixes.of_the_Twins;
            return (values_index + 1,);
        }
        return (values_index,);
    }

    // @notice append felts to uri array for item suffix
    // @implicit range_check_ptr
    // @param greatness: greatness score
    // @param values_index: index in the uri array
    // @param values: uri array
    // @return greatness_suffix_index: new index of array
    func append_item_greatness_suffix{range_check_ptr}(greatness: felt, values_index: felt, values: felt*) -> (
        greatness_suffix_index: felt
    ) {
        let check_ge_20 = is_le(20, greatness);
        if (check_ge_20 == TRUE) {
            assert values[values_index] = ' +1';
            return (values_index + 1,);
        } else {
            return (values_index,);
        }
    }

    // @notice append felts to uri array for item slot
    // @implicit range_check_ptr
    // @param slot_id: id of the slod, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_slot{range_check_ptr}(slot_id: felt, values_index: felt, values: felt*) -> (
        slot_index: felt
    ) {
        if (slot_id == 0) {
            return (values_index,);
        }
        if (slot_id == Slot.Weapon) {
            assert values[values_index + 2] = LootUriUtils.Slots.Weapon;
        }
        if (slot_id == Slot.Chest) {
            assert values[values_index + 2] = LootUriUtils.Slots.Chest;
        }
        if (slot_id == Slot.Head) {
            assert values[values_index + 2] = LootUriUtils.Slots.Head;
        }
        if (slot_id == Slot.Waist) {
            assert values[values_index + 2] = LootUriUtils.Slots.Waist;
        }
        if (slot_id == Slot.Foot) {
            assert values[values_index + 2] = LootUriUtils.Slots.Feet;
        }
        if (slot_id == Slot.Hand) {
            assert values[values_index + 2] = LootUriUtils.Slots.Hands;
        }
        if (slot_id == Slot.Neck) {
            assert values[values_index + 2] = LootUriUtils.Slots.Neck;
        }
        if (slot_id == Slot.Ring) {
            assert values[values_index + 2] = LootUriUtils.Slots.Ring;
        }

        let right_bracket = LootUriUtils.Symbols.RightBracket;
        let inverted_commas = LootUriUtils.Symbols.InvertedCommas;
        let comma = LootUriUtils.Symbols.Comma;

        assert values[values_index] = LootUriUtils.TraitKeys.Slot;
        assert values[values_index + 1] = LootUriUtils.TraitKeys.ValueKey;
        assert values[values_index + 3] = inverted_commas;
        assert values[values_index + 4] = right_bracket;
        assert values[values_index + 5] = comma;

        return (values_index + 6,);
    }

    // @notice append felts to uri array for item type
    // @implicit range_check_ptr
    // @param type_id: id of the type, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_type{range_check_ptr}(type_id: felt, values_index: felt, values: felt*) -> (
        type_index: felt
    ) {
        if (type_id == 0) {
            return (values_index,);
        }
        if (type_id == Type.generic) {
            assert values[values_index + 2] = LootUriUtils.Types.Generic;
        }
        if (type_id == Type.Weapon.generic) {
            assert values[values_index + 2] = LootUriUtils.Types.WeaponGeneric;
        }
        if (type_id == Type.Weapon.bludgeon) {
            assert values[values_index + 2] = LootUriUtils.Types.WeaponBludgeon;
        }
        if (type_id == Type.Weapon.blade) {
            assert values[values_index + 2] = LootUriUtils.Types.WeaponBlade;
        }
        if (type_id == Type.Weapon.magic) {
            assert values[values_index + 2] = LootUriUtils.Types.WeaponMagic;
        }
        if (type_id == Type.Armor.generic) {
            assert values[values_index + 2] = LootUriUtils.Types.ArmorGeneric;
        }
        if (type_id == Type.Armor.metal) {
            assert values[values_index + 2] = LootUriUtils.Types.ArmorMetal;
        }
        if (type_id == Type.Armor.hide) {
            assert values[values_index + 2] = LootUriUtils.Types.ArmorHide;
        }
        if (type_id == Type.Armor.cloth) {
            assert values[values_index + 2] = LootUriUtils.Types.ArmorCloth;
        }
        if (type_id == Type.ring) {
            assert values[values_index + 2] = LootUriUtils.Types.Ring;
        }
        if (type_id == Type.necklace) {
            assert values[values_index + 2] = LootUriUtils.Types.Necklace;
        }

        let right_bracket = LootUriUtils.Symbols.RightBracket;
        let inverted_commas = LootUriUtils.Symbols.InvertedCommas;
        let comma = LootUriUtils.Symbols.Comma;

        assert values[values_index] = LootUriUtils.TraitKeys.Type;
        assert values[values_index + 1] = LootUriUtils.TraitKeys.ValueKey;
        assert values[values_index + 3] = inverted_commas;
        assert values[values_index + 4] = right_bracket;
        assert values[values_index + 5] = comma;

        return (values_index + 6,);
    }

    // @notice append felts to uri array for item material
    // @implicit range_check_ptr
    // @param material_id: id of the material, if 0 nothing is appended
    // @param values_index: index in the uri array
    // @param values: uri array
    func append_material{range_check_ptr}(material_id: felt, values_index: felt, values: felt*) -> (
        material_index: felt
    ) {
        if (material_id == 0) {
            return (values_index,);
        }
        if (material_id == Material.generic) {
            assert values[values_index] = LootUriUtils.Materials.Generic;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.generic) {
            assert values[values_index] = LootUriUtils.Materials.MetalGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.ancient) {
            assert values[values_index] = LootUriUtils.Materials.MetalAncient;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.holy) {
            assert values[values_index] = LootUriUtils.Materials.MetalHoly;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.ornate) {
            assert values[values_index] = LootUriUtils.Materials.MetalOrnate;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.gold) {
            assert values[values_index] = LootUriUtils.Materials.MetalGold;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.silver) {
            assert values[values_index] = LootUriUtils.Materials.MetalSilver;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.bronze) {
            assert values[values_index] = LootUriUtils.Materials.MetalBronze;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.platinum) {
            assert values[values_index] = LootUriUtils.Materials.MetalPlatinum;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.titanium) {
            assert values[values_index] = LootUriUtils.Materials.MetalTitanium;
            return (values_index + 1,);
        }
        if (material_id == Material.Metal.steel) {
            assert values[values_index] = LootUriUtils.Materials.MetalSteel;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.generic) {
            assert values[values_index] = LootUriUtils.Materials.ClothGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.royal) {
            assert values[values_index] = LootUriUtils.Materials.ClothRoyal;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.divine) {
            assert values[values_index] = LootUriUtils.Materials.ClothDivine;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.brightsilk) {
            assert values[values_index] = LootUriUtils.Materials.ClothBrightsilk;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.silk) {
            assert values[values_index] = LootUriUtils.Materials.ClothSilk;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.wool) {
            assert values[values_index] = LootUriUtils.Materials.ClothWool;
            return (values_index + 1,);
        }
        if (material_id == Material.Cloth.linen) {
            assert values[values_index] = LootUriUtils.Materials.ClothLinen;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.generic) {
            assert values[values_index] = LootUriUtils.Materials.BioticGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.generic) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.blood) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonBlood;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.bones) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonBones;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.brain) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonBrain;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.eyes) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonEyes;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.hide) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonHide;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.flesh) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonFlesh;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.hair) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonHair;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.heart) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonHeart;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.entrails) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonEntrails;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.hands) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonHands;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Demon.feet) {
            assert values[values_index] = LootUriUtils.Materials.BioticDemonFeet;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.generic) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.blood) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonBlood;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.bones) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonBones;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.brain) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonBrain;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.eyes) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonEyes;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.skin) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonSkin;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.flesh) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonFlesh;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.hair) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonHair;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.heart) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonHeart;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.entrails) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonEntrails;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.hands) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonHands;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Dragon.feet) {
            assert values[values_index] = LootUriUtils.Materials.BioticDragonFeet;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.generic) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.blood) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalBlood;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.bones) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalBones;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.brain) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalBrain;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.eyes) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalEyes;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.hide) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalHide;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.flesh) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalFlesh;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.hair) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalHair;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.heart) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalHeart;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.entrails) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalEntrails;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.hands) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalHands;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Animal.feet) {
            assert values[values_index] = LootUriUtils.Materials.BioticAnimalFeet;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.generic) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.blood) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanBlood;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.bones) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanBones;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.brain) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanBrain;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.eyes) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanEyes;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.hide) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanHide;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.flesh) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanFlesh;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.hair) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanHair;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.heart) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanHeart;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.entrails) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanEntrails;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.hands) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanHands;
            return (values_index + 1,);
        }
        if (material_id == Material.Biotic.Human.feet) {
            assert values[values_index] = LootUriUtils.Materials.BioticHumanFeet;
            return (values_index + 1,);
        }
        if (material_id == Material.Paper.generic) {
            assert values[values_index] = LootUriUtils.Materials.PaperGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Paper.magical) {
            assert values[values_index] = LootUriUtils.Materials.PaperMagical;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.generic) {
            assert values[values_index] = LootUriUtils.Materials.WoodGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.generic) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.walnut) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardWalnut;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.mahogany) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardMahogany;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.maple) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardMaple;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.oak) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardOak;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.rosewood) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardRosewood;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.cherry) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardCherry;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.balsa) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardBalsa;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.birch) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardBirch;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Hard.holly) {
            assert values[values_index] = LootUriUtils.Materials.WoodHardHolly;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.generic) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftGeneric;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.cedar) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftCedar;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.pine) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftPine;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.fir) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftFir;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.hemlock) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftHemlock;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.spruce) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftSpruce;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.elder) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftElder;
            return (values_index + 1,);
        }
        if (material_id == Material.Wood.Soft.yew) {
            assert values[values_index] = LootUriUtils.Materials.WoodSoftYew;
            return (values_index + 1,);
        }
        return (values_index,);
    }

    // @notice append ascii encoding of each number in felt
    // @implicit range_check_ptr
    // @param num: number to encode
    // @param arr: array to append encoding
    // @return added_len: length of encoding
    func append_felt_ascii{range_check_ptr}(num: felt, arr: felt*) -> (added_len: felt) {
        alloc_locals;
        let (q, r) = unsigned_div_rem(num, 10);
        let digit = r + 48;  // ascii

        if (q == 0) {
            assert arr[0] = digit;
            return (1,);
        }

        let (added_len) = append_felt_ascii(q, arr);
        assert arr[added_len] = digit;
        return (added_len + 1,);
    }

    // @notice append ascii encoding of each number in uint256
    // @implicit range_check_ptr
    // @param num: number to encode
    // @param arr: array to append encoding
    // @return added_len: length of encoding
    func append_uint256_ascii{range_check_ptr}(num: Uint256, arr: felt*) -> (added_len: felt) {
        alloc_locals;
        local ten: Uint256 = Uint256(10, 0);
        let (q: Uint256, r: Uint256) = uint256_unsigned_div_rem(num, ten);
        let digit = r.low + 48;  // ascii

        if (q.low == 0 and q.high == 0) {
            assert arr[0] = digit;
            return (1,);
        }

        let (added_len) = append_uint256_ascii(q, arr);
        assert arr[added_len] = digit;
        return (added_len + 1,);
    }
}