# TrashCanKit

[![Build Status](https://travis-ci.org/nerdishbynature/TrashCanKit.svg?branch=master)](https://travis-ci.org/nerdishbynature/TrashCanKit)
[![codecov.io](https://codecov.io/github/nerdishbynature/TrashCanKit/coverage.svg?branch=master)](https://codecov.io/github/nerdishbynature/TrashCanKit?branch=master)

A Swift 2.0 API Client for Bitbuckets 2.0 API.

## Name

The name derives from how I, Piet Brauer, see the Bitbucket logo everytime I look at it and maybe my experience working with the API.

## Authentication

TrashCanKit supports both, Bitbucket Cloud and Bitbucket Enterprise.
Authentication is handled using Configurations.

There are two types of Configurations, `TokenConfiguration` and `OAuthConfiguration`.

### TokenConfiguration

`TokenConfiguration` is used if you are using Access Token based Authentication (e.g. the user
offered you an access token he generated on the website) or if you got an Access Token through
the OAuth Flow

You can initialize a new config for `bitbucket.com` as follows:

```swift
let config = TokenConfiguration(token: "12345")
```

or for Bitbucket Enterprise

```swift
let config = TokenConfiguration("https://bitbucket.example.com/api/2.0/", token: "12345")
```

After you got your token you can use it with `TrashCanKit`

```swift
TrashCanKit(config).me() { response in
  switch response {
  case .Success(let user):
    println(user.login)
  case .Failure(let error):
    println(error)
  }
}
```

### OAuthConfiguration

`OAuthConfiguration` is meant to be used, if you don't have an access token already and the
user has to login to your application. This also handles the OAuth flow.

You can authenticate an user for `bitbucket.com` as follows:

```swift
let config = OAuthConfiguration(token: "<Your Client ID>", secret: "<Your Client secret>", scopes: []) // Scopes are not supported by the API yet
config.authenticate()

```

or for Bitbucket Enterprise

```swift
let config = OAuthConfiguration("https://bitbucket.example.com/api/v3/", webURL: "https://bitbucket.example.com/", token: "<Your Client ID>", secret: "<Your Client secret>", scopes: []) // Scopes are not supported by the API yet
```

After you got your config you can authenticate the user:

```swift
// AppDelegate.swift

config.authenticate()

func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
  config.handleOpenURL(url) { config in
    self.loadCurrentUser(config) // purely optional of course
  }
  return false
}

func loadCurrentUser(config: TokenConfiguration) {
  TrashCanKit(config).me() { response in
    switch response {
    case .Success(let user):
      println(user.login)
    case .Failure(let error):
      println(error)
    }
  }
}
```

Please note that you will be given a `TokenConfiguration` back from the OAuth flow.
You have to store the `accessToken` yourself. If you want to make further requests it is not
necessary to do the OAuth Flow again. You can just use a `TokenConfiguration`.

```swift
let token = // get your token from your keychain, user defaults (not recommended) etc.
let config = TokenConfiguration(token)
TrashCanKit(config).user("bitbucketcat") { response in
  switch response {
  case .Success(let user):
    println(user.login)
  case .Failure(let error):
    println(error)
  }
}
```

## Users

### Get a single user

```swift
let username = ... // set the username
TrashCanKit().user(username) { response in
  switch response {
    case .Success(let user):
      // do something with the user
    case .Failure(let error):
      // handle any errors
  }
}
```

### Get the authenticated user

```swift
TrashCanKit().me() { response in
  switch response {
    case .Success(let user):
      // do something with the user
    case .Failure(let error):
      // handle any errors
  }
```

## Repositories

### Get repositories of authenticated user

```swift
TrashCanKit().repositories() { response in
  switch response {
    case .Success(let repositories):
      // do something
    case .Failure(let error):
      // handle any errors
  }
}
```

### Get repository

```swift
TrashCanKit().repository("nerdishbynature", name: "octokit.swift") { response in
  switch response {
    case .Success(let repository):
      // do something
    case .Failure(let error):
      // handle any errors
  }
}
```

### Get pull requests for a repository

```swift
TrashCanKit().pullRequests("nerdishbynature", repoSlug: "octokit.swift") { response in
  switch response {
    case .Success(let pullRequests, _):
      // do something
    case .Failure(let error):
      // handle any errors
  }
}
```
