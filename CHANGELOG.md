# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

-   Added new Impaled Zombiemen Mimics.  Don't get too close, that impaled corpse might still have some fight left in it.
-   Added new Withered Summoner variant!  Don't get too careless, lest a horde of the undead be upon ye!
-   Added "Clustered" spawning for Doggies as well as Withereds.  can spawn between 1 and 8 of their respective monsters, with each additional monster spawning half as often as the previous.

### Changed

-   Updated Evil Sprite to include a second fireball attack, use the new FireballerScratch method, and now come packaged with brightmaps as well as dynamic lighting effects!

## [v0.1.0] - 2024-02-23

### Added

-   New Doggy Variants!  Now in all sorts of fun colors!
-   New Withered Variants!  Now in all sorts of gross colors!
-   New Community Spawn Handler.

### Changed

-   Common logic has been refactored into new base class.
-   New per-monster `SNDINFO` entries have been added.
-   Monster Tags & Obituaries have been localized.
-   Monsters now properly use `A_HDLook` and `A_HDChase`.
-   Update Build Scripts.

## [v0.0.2]

### Changed

-   "Bootleg" version, fixed class name references.

## [v0.0.1]

### Added

-   Initial Release.

[Unreleased]: https://github.com/HDest-Community/HDest-Critters/compare/v0.1.0...HEAD

[v0.1.0]: https://github.com/HDest-Community/HDest-Critters/compare/v0.0.2...v0.1.0

[v0.0.2]: https://github.com/HDest-Community/HDest-Critters/compare/v0.0.1..v0.0.2

[v0.0.1]: https://github.com/HDest-Community/HDest-Critters/releases/tag/v0.0.1
