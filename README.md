# OG

This repository hosts a Swift Package Module to be used with apps using OpenGlück.

It contains two modules:

- `OG`, for dealing with the OpenGlück server;
- `Diably`, for all things related to the Diably apps.

## Configuration

Setup an `.env` file like so:

```bash
export TEST_OPENGLUCK_TOKEN=your-token
export TEST_OPENGLUCK_HOSTNAME=opengluck.example.com
```

## Run tests

To run the tests:

```bash
make test
```
