# My very first game written in ELM
### The game
Think of a number, the game will try and guess it.

You then tell it whether the number you have in mind is 'Lower' or 'Higher' than the number it has given you.

### Start the game
- Clone it and `cd` into it
- `elm-reactor` and navigate to `http://localhost:8000/main.elm`
- Play the game

### Deployment
- `yarn package` to create the package `public/index.html`
- `yarn deploy` to package and deploy to Firebase
- [Production app](https://elm-number-game.firebaseapp.com)

### Nice to have
- [X] Make it look nicer
- [X] Make it mobile responsive
- [ ] Have stats to show win/lost
- [ ] A better algorithms for guessing number