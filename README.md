# Bscf::Core

Short description and motivation.

## Usage

How to use my plugin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "bscf-core"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install bscf-core
```

#### Version Tasks

- **Bump Version**

  rake version:bump[type]

  - `patch`: Increases version by 0.0.1 (e.g., 1.0.0 -> 1.0.1)

  ```bash
  rake version:bump[patch]
  ```

  - `minor`: Increases version by 0.1.0 (e.g., 1.0.0 -> 1.1.0)

  ```bash
  rake version:bump[minor]
  ```

  - `major`: Increases version by 1.0.0 (e.g., 1.0.0 -> 2.0.0)

  ```bash
  rake version:bump[major]
  ```

  - `pre`: Adds or increments pre-release version (e.g., 1.0.0 -> 1.0.0-pre.1)

  ```bash
  rake version:bump[pre]
  ```

  - `release`: Removes pre-release version (e.g., 1.0.0-pre.1 -> 1.0.0)

  ```bash
  rake version:bump[release]
  ```

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
