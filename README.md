MacroExtender
=============

MacroExtender addon for 1.12.1 World of Warcraft

  - Conditional behavior for macros
  - more macro commands

> MacroExtender allows you to create conditional statement macros that are found in WOW Expansion's TBC+ and more

##Version
1.06.4

Read the **Changelog.txt** for details

#Installination
  - Download **MacroExtender**
  - Create a directory into your *World of Warcraft/Interface/AddOns* folder named **MacroExtender**
  - Extract contents of downloaded file into that new folder

#Conditional Statements
These can also be checked for falseness instead of trueness by prefixing them with **"no"**. For example, **[nocombat]** is a valid conditional and will only perform the actions following it if you are not in combat.

*Aliases are for creating a macro shorter if you run out of space*

**Retail Conditions**

condition|alias|paramater|description
:--|:--|:--|:--|
channeling|chan|spell1/spell2/../spellN|Is the player currently channeling a spell
combat|||In combat
dead|||Target is dead
equipped|eq|item type|item type is equipped (item type can be an inventory slot name or numeric slot value / item type or item subtype)
exists|||Target exists
pet||pet type|The given pet is out
harm|||Can cast harmful spells on the target
help|||Can cast helpful spells on the target
modifier|mod|shift/ctrl/alt|Holding the given key
mounted|||Self explanatory
party|||Target is in your party
raid|||Target is in your raid/party
stance|form|0/1/2/.../n|In a stance
group||party/raid|Player is in the given type of group (if argument is omitted, defaults to party)
stealth|||Stealthed (Rogue & Druid only self explanatory
swimming|swim||Only detects when submerged in water and the Breathing Timer is available, will return false if in Aquatic Form or anytype of water breathing buff
---
**Non Retail Conditions**

condition|alias|paramater|description
:--|:--|:--|:--|
mana||relational operators #n|Target mana is compared with #n
health||relational operators #n|Target health is compared with #n
shadowform|shform||Priest is currently in shadowform
petloyalty|petl|1/2/.../n|Hunter's pet loyalty level
pethappy|peth||Hunter's pet is happy
smartcast|||Mana efficiency casting, will down rank the spell until it meets the required mana cost, if doesn't meet the requirement it will fail and try to cast without rank
buff||texture|Contains buff texture
debuff||texture|Contains debuff texture
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

##Inventory Slots

The current IDs for Inventory Slots are

name|numeric value
:--|:--|
ammoslot|0
headslot|1
neckslot|2
shoulderslot|3
shirtslot|4
chestslot|5
waistslot|6
legsslot|7
feetslot|8
wristslot|9
handsslot|10
finger0slot|11
finger1slot|12
trinket0slot|13
trinket1slot|14
backslot|15
mainhandslot|16
offhandslot|17
secondaryhandslot|17
rangedslot|18
tabardslot|19
bag0slot|20
bag1slot|21
bag2slot|22
bag3slot|23

##Paramater Usage
Multiple paramaters can be included by seperating them with a *slash* [**/**] check reference table to see which is supported

**condition**:*param1/param2/.../paramN*

Following example checks if any modifier key is down and not channeling the spell drain soul. If requirements are not meet it will cast the next sequence in the list
```
/castsequence [mod,nochanneling:drain soul]drain soul;reset=target/combat corruption,curse of agony,shadow bolt,shadow bolt,shadow bolt,shadow bolt
```

To prevent the above example from continuing with the next sequence in the list which could interrupt your channeling spell, add the **[nochan]** which is the *alias for nochanneling*.
```
/castsequence [mod,nochanneling:drain soul]drain soul;[nochan]reset=target/combat corruption,curse of agony,shadow bolt,shadow bolt,shadow bolt,shadow bolt
```

***Buff / Debuff***
>Adding a prefix "**@**"  in the front of the *Buff/Debuff* will check the player instead of the target. This allows you too still direct harmful spells at the target

Following example checks for Nightfall Proc on the player if found will cast shadow bolt at target.
Castsequence will reset every 12 seconds / combat or target changes

####Correct way
```
/castx [buff:@Shadow_Twilight]shadow bolt
/castsequence [nochanneling,pet] reset=12/combat/target corruption,curse of agony,immolate
```

####Wrong way
This will not succeed as it will target the player to cast **shadow bolt**
```
/castx [target=player,buff:Shadow_Twilight]shadow bolt
```


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
#Examples
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

/castx [nochanneling:drain life]Drain Life

/eq [smartcast]firestone
```

>To create a warlock healthstone without repeative editing of a macro each spell rank learnt, use the smartcast option. Passing the spell without any rank information such as *minor/lesser/../major* If major is learnt by the player then it will cast *Create Soulstone (Major)()* automatically for the player if the mana requirement is met, if not it will down rank until successful. This works with all ***Create [Spell's]/Conjure [Spell's]***,

```
/castx [smartcast]create healthstone
```

>To use the best healthstone found in the player inventory ordered as follows *major/greater/../lesser*

```
/use [smartcast]healthstone
```

>Create healthstone while a modifier key is down otherwise use the healthstone

```
/castx [mod,smartcast]create healthstone
/use [nomod,smartcast]healthstone
```

>Bellow is equivalent of the example above just shorter

```
/castx [mod,smartcast]create healthstone;[smartcast]healthstone
```

>Following macro allows you to create a spellstone if a modifer key is down, if no modifer key is down then equip it if not already equipped then use it

```
/castx [mod,smartcast]create spellstone;[nomod,smartcast,noequipped:17]spellstone;17
```

__Mage__

>One single macro to rule them all, this will allow you to create or use the mana crystal if found in your inventory. To use the best conjured mana crystal found in the player inventory ordered as follows *ruby/citrine/jade/agate*, Only creating the mana crystal is class specific, otherwise it will look into your inventory

```
/use [smartcast]conjure mana
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