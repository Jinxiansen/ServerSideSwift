

# Install on macOS

To use Vapor on macOS, you just need to have Xcode 9.3 or greater installed.

## Install Xcode

Install [Xcode 9.3 or greater](https://itunes.apple.com/us/app/xcode/id497799835) from the Mac App Store.

> After Xcode has been downloaded, you must open it to finish the installation. This may take a while.


### Verify Installation

Double check the installation was successful by opening Terminal and running:

```swift
swift --version
```

You should see output similar to:

```
Apple Swift version 4.1.0 (swiftlang-900.0.69.2 clang-900.0.38)
Target: x86_64-apple-macosx10.9
```

Vapor requires Swift 4.1 or greater.


## Install Homebrew

If you don’t have it yet I highly recommend to get it. It makes it super easy for you to install dependencies like PostgreSQL. To install Homebrew execute the following in your terminal:

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

We will also install brew services. It will make it incredibly easy to start the PostgreSQL server and let it start alongside with your mac! It’s awesome ✨!

`brew tap homebrew/services`

Now whenever you want to know what services are running just execute:

`brew services list`

> You must install Homebrew before you can install vapor.


## Install Vapor

Now that you have Swift 4.1, let's install the Vapor Toolbox.

The toolbox includes all of Vapor's dependencies as well as a handy CLI tool for creating new projects.

```swift
brew install vapor/tap/vapor
```


### Verify Installation

Double check the installation was successful by opening Terminal and running:

```
vapor --help
```

You should see a long list of available commands.


## Install PostgreSQL

Installing PostgreSQL with Homebrew is so easy, what am I even here for 😄?

```
brew install postgresql
```

That’s it. Done. Now to init postgresql just execute the following command:

```
initdb /usr/local/var/postgres
```

Next start postgresql using services with:

```
brew services start postgresql
```

See how easy brew services makes it? Postgresql now starts alongside your Mac !

Now let's create a user we want to use in our project. To create a new user, we need to execute it in the terminal:

```
createuser vapor -P
```

Then,let's create the database used by this user:

```
createdb vaporDebugDB -O vapor -E UTF8 -e
```

Now, you can open the project, 

1. cd to `VaporServer` directory, 
2. execute `vapor build && vapor xcode -y`,

3. wait for Xcode to run, click `Run` to start the project.


### Done
Now that you have installed Vapor, let's get started! good luck! 🤝 🤝 

