**Important**
--

This project contains two parts - UI and DApp. Also you need VeChain `thor` node on your local machine.

You need to follow next folder structure:

 -- Project folder
 
 ---- dropchain-poc-ui
 
 ---- dropchain-poc
 
 ---- thor
 
 **Requirments**
 --
 
 1. NodeJS - `http://blog.teamtreehouse.com/install-node-js-npm-mac`
 2. Yarn - `https://yarnpkg.com/lang/en/docs/install/#mac-stable`
 3. Go - `https://golang.org/dl/`
 
 
**Project setup**
--

**VeChain `thor` client**

1. Clone `https://github.com/vechain/thor.git` this repo into `thor` folder. Look at important section above.
2. Go to `thor` folder.
3. Run `make dep` in terminal
4. Run `make` in terminal

**dropchain-poc**

1. Go to dropchain-poc folder
2. You need to install project dependencies: run `yarn` in terminal in in `dropchain-poc` folder

**Start project**
--

1. Open two terminal instances in `dropchain-poc` folder
2. In first terminal run following command `yarn run-thor`
3. Switch to second terminal
4. Run `yarn run-dapp` in `dropchain-poc` folder
