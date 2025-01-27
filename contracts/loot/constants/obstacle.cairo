// -----------------------------------
//   Loot.ObstacleConstants
//   Loot
//
// MIT License
// -----------------------------------

%lang starknet

from starkware.cairo.common.registers import get_label_location
from contracts.loot.constants.item import Type

// Structure for the adventurer Obstacle primitive
struct Obstacle {
    Id: felt,  // item id 1 - 100
    Type: felt,  // same as Loot weapons: magic, bludgeon, blade
    Rank: felt,  // same as Loot weapons: 1 is the strongest
    Prefix_1: felt,  // First part of the name prefix (i.e Tear)
    Prefix_2: felt,  // Second part of the name prefix (i.e Bearer)
    Greatness: felt,  // same as Loot weapons 0-20
}

namespace ObstacleConstants {
    namespace ObstacleIds {
        const DemonicAlter = 1;
        const Curse = 2;
        const Hex = 3;
        const MagicLock = 4;
        const DarkMist = 5;

        const CollapsingCeiling = 6;
        const CrushingWalls = 7;
        const Rockslide = 8;
        const TumblingBoulders = 9;
        const SwingingLogs = 10;

        const PendulumBlades = 11;
        const FlameJet = 12;
        const PoisonDart = 13;
        const SpikedPit = 14;
        const HiddenArrow = 15;
    }

    namespace ObstacleRank {
        const DemonicAlter = 1;
        const Curse = 2;
        const Hex = 3;
        const MagicLock = 4;
        const DarkMist = 5;

        const CollapsingCeiling = 1;
        const CrushingWalls = 2;
        const Rockslide = 3;
        const TumblingBoulders = 4;
        const SwingingLogs = 5;

        const PendulumBlades = 1;
        const FlameJet = 2;
        const PoisonDart = 3;
        const SpikedPit = 4;
        const HiddenArrow = 5;
    }

    namespace ObstacleType {
        const DemonicAlter = Type.Weapon.magic;
        const Curse = Type.Weapon.magic;
        const Hex = Type.Weapon.magic;
        const MagicLock = Type.Weapon.magic;
        const DarkMist = Type.Weapon.magic;

        const CollapsingCeiling = Type.Weapon.bludgeon;
        const CrushingWalls = Type.Weapon.bludgeon;
        const Rockslide = Type.Weapon.bludgeon;
        const TumblingBoulders = Type.Weapon.bludgeon;
        const SwingingLogs = Type.Weapon.bludgeon;

        const PendulumBlades = Type.Weapon.blade;
        const FlameJet = Type.Weapon.blade;
        const PoisonDart = Type.Weapon.blade;
        const SpikedPit = Type.Weapon.blade;
        const HiddenArrow = Type.Weapon.blade;
    }
}

namespace ObstacleUtils {
    func get_rank_from_id{syscall_ptr: felt*, range_check_ptr}(obstacle_id: felt) -> (rank: felt) {
        alloc_locals;

        let (label_location) = get_label_location(labels);
        return ([label_location + obstacle_id - 1],);

        labels:
        dw ObstacleConstants.ObstacleRank.DemonicAlter;
        dw ObstacleConstants.ObstacleRank.Curse;
        dw ObstacleConstants.ObstacleRank.Hex;
        dw ObstacleConstants.ObstacleRank.MagicLock;
        dw ObstacleConstants.ObstacleRank.DarkMist;
        dw ObstacleConstants.ObstacleRank.CollapsingCeiling;
        dw ObstacleConstants.ObstacleRank.CrushingWalls;
        dw ObstacleConstants.ObstacleRank.Rockslide;
        dw ObstacleConstants.ObstacleRank.TumblingBoulders;
        dw ObstacleConstants.ObstacleRank.SwingingLogs;
        dw ObstacleConstants.ObstacleRank.PendulumBlades;
        dw ObstacleConstants.ObstacleRank.FlameJet;
        dw ObstacleConstants.ObstacleRank.PoisonDart;
        dw ObstacleConstants.ObstacleRank.SpikedPit;
        dw ObstacleConstants.ObstacleRank.HiddenArrow;
    }

    func get_type_from_id{syscall_ptr: felt*, range_check_ptr}(obstacle_id: felt) -> (type: felt) {
        alloc_locals;

        let (label_location) = get_label_location(labels);
        return ([label_location + obstacle_id - 1],);

        labels:
        dw ObstacleConstants.ObstacleType.DemonicAlter;
        dw ObstacleConstants.ObstacleType.Curse;
        dw ObstacleConstants.ObstacleType.Hex;
        dw ObstacleConstants.ObstacleType.MagicLock;
        dw ObstacleConstants.ObstacleType.DarkMist;
        dw ObstacleConstants.ObstacleType.CollapsingCeiling;
        dw ObstacleConstants.ObstacleType.CrushingWalls;
        dw ObstacleConstants.ObstacleType.Rockslide;
        dw ObstacleConstants.ObstacleType.TumblingBoulders;
        dw ObstacleConstants.ObstacleType.SwingingLogs;
        dw ObstacleConstants.ObstacleType.PendulumBlades;
        dw ObstacleConstants.ObstacleType.FlameJet;
        dw ObstacleConstants.ObstacleType.PoisonDart;
        dw ObstacleConstants.ObstacleType.SpikedPit;
        dw ObstacleConstants.ObstacleType.HiddenArrow;
    }
}
