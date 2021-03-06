# LAA Court Data Adaptor

This application acts as a proxy between the HMCTS Common Platform and LAA systems.

Its main functions will be data translation / adaptation, and queueing of requests.

As the Common Platform API is not yet live to us, we have also created a Mock of it, which can be found [here](https://github.com/ministryofjustice/hmcts-common-platform-mock-api/)

Run this in parallel to the Court Data Adaptor to mock the Common Platform API.


## Set up

This is a standard 6 Rails API application. Using Postgres 12.1 as a database.

Clone the repo, then run:

```
$ bundle install
$ rails db:setup
```

You can then start the application server by running:

```
$ rails s
```

To run background jobs using redis, you need to have redis available on port 6379, then run

```
$ bundle exec sidekiq
```

Alternatively, set `INLINE_SIDEKIQ` to `true` in your development environment to process jobs inline.


### Set up using docker-compose

Clone the repo, and then run
```
$ docker-compose up
```
The app should be running at `http://localhost:3000`

#### Running tests in docker

Tests can be executed in the docker instance
```
$ docker-compose run app bundle exec rspec
```

### API Authentication

Create an OAuth Application for each system that needs to authenticate to the adaptor via the console.
```ruby
application = Doorkeeper::Application.create(name: 'HMCTS Common Platform')
```
The client credentials are available against the `application` as `application.uid` and `application.secret`
Use these credentials to generate an `access_token` by making a call to the OAuth endpoint described in the [schema](https://github.com/ministryofjustice/laa-court-data-adaptor/blob/master/schema/schema.md#oauth-endpoints-authentication).


##### Making authenticated requests:
Send the `access_token` provided by the OAuth endpoint as a Bearer Token.
eg:
```curl
curl --get \
--url 'https://API_HOST/api/internal/v1/prosecution_cases' \
--data-urlencode 'filter[name]=Boris Lubowitz' \
--data-urlencode 'filter[date_of_birth]=1981-08-22' \
--data-urlencode 'include=defendants' \
--header 'Authorization: Bearer <access_token>'
```

### Git hooks for Rubocop

Rubocop can be set up to run pre-commits.

Please see this [PR](https://github.com/ministryofjustice/laa-court-data-adaptor/pull/12)

### API Schema

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/api-docs/index.html.

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database. See [here](https://github.com/ministryofjustice/laa-court-data-adaptor#api-authentication) for details.

To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec. Add appropriate tests and content to the spec, then run `rake rswag`. The new endpoint should now appear in the Swagger UI interface.

### Decrypting secrets for deployment

**NOTE:** **git-crypt** is required to store secrets needed for **dev**, **test**, **uat**, **stage** and **production** environments.
To be able to modify those secrets, **git-crypt** needs to be set up according to the following
[guide](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/git-crypt-setup.html#git-crypt).

This requires your gpg key to have been added to git-crypt.  Liaise with another developer to action the steps in [git-crypt.md](docs/git-crypt.md)

Once the pull request has been merged, pull master and run

```
git-crypt unlock
```
