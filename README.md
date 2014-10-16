MacroExtender
=============

MacroExtender addon for 1.12.1 World of Warcraft

  - Conditional behavior for macros
  - more macro commands

> MacroExtender allows you to create conditional statement macros that are found in WOW Expansion's TBC+ and more

Version
----
1.05

Conditional Statements
-----------
These can also be checked for falseness instead of trueness by prefixing them with **"no"**. For example, **[nocombat]** is a valid conditional and will only perform the actions following it if you are not in combat.

**Retail Conditions**

condition|paramater|description
:--|:--|:--|
channeling||Is the player currently channeling a spell
combat||In combat
dead||Target is dead
equipped|item type|item type is equipped (item type can be an inventory slot, item type, or item subtype)
exists||Target exists
pet|pet type|The given pet is out
harm||Can cast harmful spells on the target
help||Can cast helpful spells on the target
mod|shift/ctrl/alt|Holding the given key
mounted||Self explanatory
party||Target is in your party
raid||Target is in your raid/party
stance|0/1/2/.../n|In a stance
group|party/raid|Player is in the given type of group (if argument is omitted, defaults to party)
stealth||Stealthed (Rogue & Druid only self explanatory
swimming||Only detects when submerged in water and the Breathing Timer is available, will return false if in Aquatic Form or anytype of water breathing buff
---
**Non Retail Conditions**

condition|paramater|description
:--|:--|:--|
mana|relational operators #n|Target mana is compared with #n
health|relational operators #n|Target health is compared with #n
shadowform||Priest is currently in shadowform
petloyalty|1/2/.../n|Hunter's pet loyalty level
pethappy||Hunter's pet is happy
smartcast||Mana efficiency casting, will down rank the spell until it meets the required mana cost, if doesn't meet the requirement it will fail and try to cast without rank
buff|texture|Contains buff texture
debuff|texture|Contains debuff texture
---

>Relational operators for mana / health condition for comparison

operator|description
:--|:--|
<|Less than
>|Greater than
>=|Greater than or equal to
<=|Less than or equal to
==|Equal to
---

*Buff and Debuff should be used with risk, There is no correct way to determine what buff or debuff belongs to a specific caster*

> Following macros that accept conditional behaivor

command|alias|description
:--|:--|:--
castx|use|Extended version of cast which allow conditional behaviro
castsequence|castseq|Cast spells in successive order
castrandom|userandom|Cast a random spell from the list
equip|eq|Equip items from the list
pick||Picks up a item in the players inventory
stopcasting||Stop casting or channeling a spell
dismount||Dismounts your character
cancelform||Cancels your current shapeshift/shadow/ghost wolf form
---
___Pet commands___

command|description
:--|:--
petassist|Player will assist the pet
petaggressive|Sets your pet to aggressive mode
petdefensive|Sets your pet to defensive mode
petpassive|Sets your pet to passive mode
petattack|Instructs your pet to attack
petfollow|Sets your pet to follow you around
petstay|Sets your pet to stay in its current location
---

> Macro's that don't have conditional behavior

command|description
:--|:--
reload|Reloads the user interface
---
Examples
-----------
__Warrior__
```
/castx [stance:1]Heroic Strike;Rend
/castx [equipped:shields]defensive stance
```

__Hunter__
```
/castx [pet,nopethappy]feed pet
/pick [pet:boar,nopethappy]roasted quail
```

__Rogue__
```
/castx [stealth]Rupture;Sinister Strike
```

__Warlock__
```
/castx [smartcast]Shadow Bolt
/castx [mod:ctrl]Immolate;Curse of Agony
/castx [mod:shift,harm,nochanneling]Drain Life;Health Funnel
/castx [harm,nodebuff:Shadow_CurseOfSargeras]Curse of Agony;Corruption

/castrandom [combat]shadow bolt,immolate;curse of agony,corruption

/castsequence reset=target/combat corruption,curse of agony,immolation,shadow bolt,shadow bolt,shadow bolt

/castsequence reset=30 demon armor, soul link

/castsequence [health:>=25]immolate,corruption,curse of agony,shadow bolt,shadow bolt,shadow bolt;drain soul

/petassist [pet,nomod,combat]
/petattack [pet,mod:shift]
```

__Druid__
```
/castx [nostance:3]cat form;[stance:3,nostealth]prowl;pounce
```

__Misc__
```
/dismount [combat,mounted]
/castrandom [nocombat]corruption,immolate,curse of agony;shadow bolt

/equip [stance:2]The Face of Death, Quel'Serrar

/equip [nocombat] dreadmist mask,dreadmist robe,dreadmist bracers,dreadmist wraps,dreadmist belt,dreadmist leggings,dreadmist sandals,blade of the new moon,rune band of wizardry,tome of the lost
```