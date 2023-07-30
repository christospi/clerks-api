# My Clerks API

This is a Dockerized Rails 7 app that provides an interface to manage and retrieve `Clerk` data. The application uses the [RandomUser.com](http://randomuser.com/) API to populate the database with `Clerk` entries (initialized with random user attributes) and provides endpoints to fetch and filter the data.

Clerks API was built using:

- Ruby: `3.2.1`
- Rails: `7.0.6`
- PostgreSQL: `15.3`
- Docker: `20.10.5` & Docker-compose: `1.25.0`

## Introduction

The purpose of this project is to showcase best practices, coding principles, and structuring of a Rails API application. For more information on the requirements, check: [Clerks API requirements](https://github.com/hatchways-community/7e25dd52c32e4cf3a1822a0d900665e2/tree/main#readme)

## Prerequisites

Ensure you have Docker and Docker Compose installed on your machine.

To install Docker, follow the instructions here: https://docs.docker.com/engine/install/

To install Docker Compose Plugin, follow the instructions here: https://docs.docker.com/compose/install/

All the actual application dependencies are handled by Docker. Check `Dockerfile` and `docker-compose.yml` files for more info on that.

## Setup

1. **Clone the repository:**

    ```bash
    git clone git@github.com:hatchways-community/7e25dd52c32e4cf3a1822a0d900665e2.git
    ```

2. **Navigate to the application directory:**

    ```bash
    cd 7e25dd52c32e4cf3a1822a0d900665e2/clerks-api
    ```

3. **Environment configuration:**
The application uses environment variables for configuration. A `.env.sample` file is provided in the repository as a template.
    1. Copy the `.env.sample` file to create a new `.env` file:

        ```bash
        cp .env.sample .env
        ```

    2. Open the `.env` file in a text editor and replace the placeholder values with your actual values.
4. **Build and start the Docker containers:**

    ```bash
    docker-compose up --build
    ```

    The database will be prepared automatically during the startup process.


## Running the application

Once the Docker containers are up and running, the Clerks-API will be available at `http://localhost:3000`

## Running tests

To run the test suite, execute the following command:

```bash
docker-compose -f docker-compose.test.yml up --build
```

This will build and start the Docker containers and run all the `rspec` tests.

## Endpoints

The API exposes the following endpoints:

- `POST /populate`: Populates the database with 5K users from RandomUser API, creating a `Clerk` record for each one.
- `GET /clerks`: Returns a list of `Clerk` records sorted by registration date, with the most recent users appearing first. Supports optional parameters for filtering and pagination. Currently supported optional parameters:
    - `limit`: A limit on the number of Clerks to be returned, ranging between 1 and 100.
    - `starting_after`: A cursor for use in pagination. `starting_after` is a Clerk ID that
    defines your place in the list. For instance, if you make a list request and receive 100
    objects, ending with `ID=obj_foo`, your subsequent call can include `starting_after=obj_foo` in order to fetch the next page of the list.
    - `ending_before`: A cursor for use in pagination. `ending_before` is a Clerk ID that
    defines your place in the list. For instance, if you make a list request and receive 100
    objects, `starting with ID=obj_bar`, your subsequent call can include `ending_before=obj_bar` in order to fetch the previous page of the list.
    - `email`: A case-insensitive filter on the list based on Clerk's email field.

    For a few samples, check the following section (Sample Requests and Responses).


## **Sample Requests and Responses**

This section provides examples of how to call the supported endpoints and what kind of responses you can expect.

### **Populate Clerks**

**Request:**

```bash
curl -X POST -H "Accept: application/json" http://localhost:3000/populate
```

**Response:**

Upon successful completion, this endpoint will return a status of 200 and a message indicating the operation was successful.

```json
{
  "success_count": 5,
  "total_count": 5,
  "message": "All 5 users were created successfully.",
  "status": "success"
}
```

### **Get Clerks**

**Request:**

```bash
curl -X GET -H "Accept: application/json" http://localhost:3000/clerks
```

**Response:**

This endpoint returns a list of clerks. The response contains an array of Clerk objects. Each Clerk object includes **`id`**, **`firstname`**, **`lastname`**, **`email`**, **`phone`**, **`picture`**, and **`registration_date`** fields.

```json
[
  {
    "id": 5,
    "first_name": "Annabelle",
    "last_name": "Wilson",
    "email": "annabelle.wilson@example.com",
    "phone": "(307)-178-1138",
    "registration_date": "2022-05-03T07:26:23.952Z",
    "created_at": "2023-07-29T13:34:21.247Z",
    "updated_at": "2023-07-29T13:34:21.253Z"
  },
  // ... more records
]
```

You can also use query parameters to filter and paginate the results. Here's an example that fetches Clerks with a limit of 20, starting after Clerk with ID 100:

**Request:**

```bash
curl -X GET -H "Accept: application/json" "http://localhost:3000/clerks?limit=20&starting_after=100"
```

This will return up to 20 clerks whose ID comes after 100, sorted by registration date in descending order.

## Project Structure

The project follows a typical Rails application structure with models, controllers, and services with a few additions. Apart from the expected classes/modules supporting our main model (`Clerk`), it includes the following:

- **Services**: Located in `lib/services` directory, these files encapsulate business logic that doesn't belong in models or controllers of our app. This includes the `RandomUser` module used to fetch user data from the [RandomUser.com](http://randomuser.com/) API.
- **Utilities:** General purpose helpers that may be used across different models, services, or other parts of the application (DRY is our motto here!). These utilities can be found under `lib/utils`. Currently, we only have `Downloader` module, which abstracts the process of a file download (used to fetch user pictures from RandomUser.com).
- **Serializers**: Located in the `app/serializers` directory, these files handle the conversion of data for application models. It contains `RandomUserSerializer` which is responsible for transforming data from the Random User API into a format that can be used by the `Clerk` model.
- **Specs**: Test coverage is provided by RSpec. Located in the `spec` directory, these files contain the test suite for our application, including unit tests for models and controller actions, along with a few request tests.
- **Dockerfile and docker-compose.yml**: These files define the Docker configuration for setting up and running the application in a Docker container. It handles both our database (Postgres) and the Rails app.
- **.env.sample:** Sample configuration files for the required environment variables. Following the instructructions in **Setup** section, you should create a new local file named `.env` in application root directory with the appropriate values.

## **Troubleshooting**

If you encounter issues while setting up the application, you may need to rebuild your Docker images:

```bash
docker-compose down
docker-compose up --build
```

You may also need to check the container logs to debug any issues:

```bash
docker-compose logs
```

## Wrapping Up 🙏

That was a blast! 🚀 Really enjoyed putting this together – it's not every day you get to juggle API endpoints, random users, and Docker all at the same time!

Big thanks for throwing this challenge my way. Hope you enjoy checking it out as much as I did building it. And if there's anything that made you go "hmm" or "huh?" (of course there will be!), I'm all ears. Always keen to learn and grow.

Thanks!
