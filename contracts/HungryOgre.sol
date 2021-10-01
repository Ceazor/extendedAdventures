pragma solidity ^0.4.0;

contract Hungry Ogre {
function Hungry_Ogre(){

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./interfaces/IRarity.sol";
import "./interfaces/IAttributes.sol";
import "./interfaces/ISkills.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IRandomCodex.sol";
import "./interfaces/boarAdventure.sol"; //this needs to be checked we will use items from there.


contract hungryOgreAdventure {

int public constant dungeon_health = 22;
int public constant dungeon_damage = 6;
int public constant dungeon_to_hit = 3;
int public constant dungeon_armor_class = 3;
int public ogre_population =0;
uint constant DAY = 1 days;
mapping(uint => uint) public actions_log;

IRarity public rm;
attributes public attr;
ISkills public skills;
IRandomCodex public random;
IrERC20 public mushroom;
IrERC20 public berries;
IrERC20 public meat;

enum RewardParlay {
None,
PrettyRock,
Topaz,
OgreMap //this can be a req for another adventure
}

enum RewardKill {
None,
GoblinToe,
OgreBlood,
OgreHeart
}

constructor(address _rmAddr, address _attrAddr, address _skills, address _random, address _pretty_rock address _topaz, address _ogre_map, address _goblin_toe, address _ogre_blood, address _ogre_heart) {
rm = IRarity(_rmAddr);
attr = attributes(_attrAddr);
skills = ISkills(_skills);
random = IRandomCodex(_random);
PrettyRock = IrERC20(_pretty_rock);
Topaz = IrERC20(_topaz);
OgreMap = IrERC20(_orge_map);
GoblinToe = IrERC20(_goblin_toe);
OgreBlood = IrERC20(_ogre_blood);
OgreHeart = IrERC20(_ogre_heart);
}

function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
return rm.getApproved(_summoner) == msg.sender || rm.ownerOf(_summoner) == msg.sender;
}

/*KILL MECHANISM */

function health_by_class(uint _class) internal pure returns (uint health) {
if (_class == 1) {
health = 12;
} else if (_class == 2) {
health = 6;
} else if (_class == 3) {
health = 8;
} else if (_class == 4) {
health = 8;
} else if (_class == 5) {
health = 10;
} else if (_class == 6) {
health = 8;
} else if (_class == 7) {
health = 10;
} else if (_class == 8) {
health = 8;
} else if (_class == 9) {
health = 6;
} else if (_class == 10) {
health = 4;
} else if (_class == 11) {
health = 4;
}
}

function health_by_class_and_level(uint _class, uint _level, uint32 _const) internal pure returns (uint health) {
int _mod = modifier_for_attribute(_const);
int _base_health = int(health_by_class(_class)) + _mod;
if (_base_health <= 0) {
_base_health = 1;
}
health = uint(_base_health) * _level;
}

function base_attack_bonus_by_class(uint _class) internal pure returns (uint attack) {
if (_class == 1) {
attack = 4;
} else if (_class == 2) {
attack = 3;
} else if (_class == 3) {
attack = 3;
} else if (_class == 4) {
attack = 3;
} else if (_class == 5) {
attack = 4;
} else if (_class == 6) {
attack = 3;
} else if (_class == 7) {
attack = 4;
} else if (_class == 8) {
attack = 4;
} else if (_class == 9) {
attack = 3;
} else if (_class == 10) {
attack = 2;
} else if (_class == 11) {
attack = 2;
}
}

function base_attack_bonus_by_class_and_level(uint _class, uint _level) internal pure returns (uint) {
return _level * base_attack_bonus_by_class(_class) / 4;
}

function modifier_for_attribute(uint _attribute) internal pure returns (int _modifier) {
if (_attribute == 9) {
return -1;
}
return (int(_attribute) - 10) / 2;
}

function attack_bonus(uint _class, uint _str, uint _level) internal pure returns (int) {
return  int(base_attack_bonus_by_class_and_level(_class, _level)) + modifier_for_attribute(_str);
}

function to_hit_ac(int _attack_bonus) internal pure returns (bool) {
return (_attack_bonus > dungeon_armor_class);
}

function damage(uint _str) internal pure returns (uint) {
int _mod = modifier_for_attribute(_str);
if (_mod <= 1) {
return 1;
} else {
return uint(_mod);
}
}

function armor_class(uint _dex) internal pure returns (int) {
return modifier_for_attribute(_dex);
}

function random_reward_kill(uint _summoner) internal view returns (RewardKill reward) {
uint res = random.dn(_summoner, 4);
if (res == 0) {
return RewardKill(1); //bodyparts
}
return RewardKill(res);
}

function mint_reward_kill(uint receiver, uint qty, RewardKill reward) internal {
if (reward == RewardKill.GoblinToe) {
GoblinToe.mint(receiver, qty);
}

if (reward == RewardKill.OgreBlood) {
OgreBlood.mint(receiver, qty);
}

if (reward == RewardKill.OgreHeart) {
OgreHeart.mint(receiver, qty);
}
}

function simulate_kill(uint _summoner) public view returns (uint reward, RewardKill reward_type) {
uint _level = rm.level(_summoner);
uint _class = rm.class(_summoner);
(uint32 _str, uint32 _dex, uint32 _const,,,) = attr.ability_scores(_summoner);
int _health = int(health_by_class_and_level(_class, _level, _const));
int _dungeon_health = dungeon_health;
int _damage = int(damage(_str));
int _attack_bonus = attack_bonus(_class, _str, _level);
bool _to_hit_ac = to_hit_ac(_attack_bonus);
bool _hit_ac = armor_class(_dex) < dungeon_to_hit;
reward_type = random_reward_kill(_summoner);
if (_to_hit_ac) {
for (reward = 10; reward >= 0; reward--) {
_dungeon_health -= _damage;
if (_dungeon_health <= 0) {break;}
if (_hit_ac) {_health -= dungeon_damage;}
if (_health <= 0) {return (0, RewardKill.None);}
}
}
}

function kill(uint _summoner) external returns (uint reward, RewardKill reward_type) {
require(ogre_population > 0, "no orges to kill");
require(_isApprovedOrOwner(_summoner));
require(block.timestamp > actions_log[_summoner]);
actions_log[_summoner] = block.timestamp + DAY;
(reward, reward_type) = simulate_kill(_summoner);
mint_reward_kill(_summoner, reward, reward_type);
ogre_population -= 1;
}

/*PARLAY MECHANISM */

function food_on_hero(uint _mushrooms, uint _berries, uint _meat) internal pure returns (uint points) {
if (_mushrooms >= 1, _berries == 0, _meat ==0) {
points = 1;
} else if (_mushrooms == 0, _berries >= 1, _meat ==0) {
points = 2;
} else if (_mushrooms == 0, _berries == 0, _meat >=1) {
points = 4;
} else if (_mushrooms >= 1, _berries >= 1, _meat ==0) {
points = 4;
} else if (_mushrooms >= 1, _berries == 0, _meat >=1) {
points = 6;
} else if (_mushrooms >= 1, _berries == 1, _meat ==1) {
points = 10;
} else if (_mushrooms == 0, _berries >= 1, _meat >=1) { {
points = 8;
}
}
function burn_food(uint _mushrooms, uint _berries, uint _meat, uint _points) {
if (points >= 1)
        if (_mushrooms >=1)
        function burn _mushrooms(amount: uint256)
        amount: uint256: 1000000000000000000
        if (_berries >=1)
        function burn berries(amount: uint256)
        amount: uint256: 1000000000000000000
        if (_meat >=1)
        function burn _meat(amount: uint256)
        amount: uint256: 1000000000000000000
}

}
}
function multiplier_points_by_level(uint _points, uint level) internal pure returns (uint points) {
if (level == 0) {
return _points;
}else{
points = _points * level;
}
}

// skill checks

function bonus_by_bluff(uint _points, uint _summoner) internal view returns (uint points) {
uint8[36] memory _skills = skills.get_skills(_summoner);
uint bluff = _skills[3];
points = _points + (bluff * 2);
}
function bonus_by_diplomacy(uint _points, uint _summoner) internal view returns (uint points) {
uint8[36] memory _skills = skills.get_skills(_summoner);
uint diplomacy = _skills[8];
points = _points + (diplomacy * 2);
}
function bonus_by_intimidate(uint _points, uint _summoner) internal view returns (uint points) {
uint8[36] memory _skills = skills.get_skills(_summoner);
uint intimidate = _skills[17];
points = _points + (intimidate * 1);
}
function bonus_by_sense_motive(uint _points, uint _summoner) internal view returns (uint points) {
uint8[36] memory _skills = skills.get_skills(_summoner);
uint sense_motive = _skills[27];
points = _points + (sense_motive * 2);
}
function bonus_by_speak_language(uint _points, uint _summoner) internal view returns (uint points) {
uint8[36] memory _skills = skills.get_skills(_summoner);
uint speak_language = _skills[29];
points = _points + (speak_language * 3);
}

function bonus_by_attr(uint _points, uint _summoner) internal view returns (uint points) {
(,,,uint32 _cha) = attr.ability_scores(_summoner);
points = _points + ((_cha) / 2);
}

function mint_reward_reproduce(uint receiver, uint qty, RewardReproduce reward) internal {
if (reward == RewardReproduce.PrettyRock) {
PrettyRock.mint(receiver, qty);
}

if (reward == RewardReproduce.Topaz) {
Topaz.mint(receiver, qty);
}

if (reward == RewardReproduce.OgreMap) {
OgreMap.mint(receiver, qty);
}
}

function simulate_reproduce(uint _summoner) public view returns (uint reward) {
uint _level = rm.level(_summoner);
uint _class = rm.class(_summoner);
reward = multiplier_points_by_level(reward, _level);
reward = bonus_by_bluff(reward, _summoner);
reward = bonus_by_diplomacy(reward, _summoner);
reward = bonus_by_intimidate(reward, _summoner);
reward = bonus_by_sense_motive(reward, _summoner);
reward = bonus_by_speak_language(reward, _summoner);
reward = bonus_by_attr(reward, _summoner);
}

function reproduce(uint _summoner, RewardReproduce expected_reward) external returns (uint reward) {
require(_isApprovedOrOwner(_summoner));
require(block.timestamp > actions_log[_summoner]);
actions_log[_summoner] = block.timestamp + DAY;
(reward) = simulate_reproduce(_summoner);
mint_reward_reproduce(_summoner, reward, expected_reward);
ogre_population += 1;
}
}
