# Puzzles Reloaded

An implementation of the [Simon Tatham Portable Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/) for iOS & iPadOS

In addition to the games from the main collections, it also provides a set of new games by [x-sheep](https://github.com/x-sheep/puzzles-unreleased). 50 games in total are currently supported!

[<img width="240" height="80" alt="Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917" src="https://github.com/user-attachments/assets/60ed9838-7c80-43b6-83a9-f3e99a0fccbc" />](https://apps.apple.com/us/app/puzzles-reloaded/id6504365885)


## Reporting issues

To report issues, please open an issue on the GitHub board for tracking. If for some reason you cannot do so, feel free to send me an email.

## Contributions

Contributions are welcome! Please associate all changes to an open issue & feel free to send me an email or pull request to discuss!

## Join the Testflight

Interested in testing changes early or reporting issues? Join the testflight to get early access and help guide the future of the app!

[Puzzles Reloaded- Join Testflight](https://testflight.apple.com/join/WTgP9Te4)


## Adding new games & maintaining submodules

The app should compile in xcode out of the box with no added dependencies.

The puzzle collection maintains a list of games, in a locally cached file named `generated-games.h`. This was created from the cmake commands nested inside simon-tatham puzzles. When new games are added or new file dependencies are added from this or other submodules, these files must be wired into the app's compiler & new games added to `generated-games.h` to be picked up correctly.

### Links

- [Puzzles Reloaded Website](https://kyledswarner.github.io/puzzles)
- [Simon Tatham Portable Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/)
- [Simon Tatham Puzzles Git Repo](https://git.tartarus.org/?p=simon/puzzles.git)
- [Additional Puzzles by x-sheep](https://github.com/x-sheep/puzzles-unreleased)
