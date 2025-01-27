# 🚨 Please hold on

**If you're starting a new project with a empty database, use UUID v7 instead.**

**If you’re trying to address database slowness caused by non-time-ordered UUIDs, such as UUIDv4, use UUIDv7 instead.**

➡️ Read more at:
- https://uuid7.com
- https://buildkite.com/resources/blog/goodbye-integers-hello-uuids/

---

![Ruby](https://github.com/rafaelsales/ulid/workflows/Ruby/badge.svg)
[![Gem Downloads](http://img.shields.io/gem/dt/ulid.svg)](https://rubygems.org/gems/ulid)
[![GitHub License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rafaelsales/ulid)

# ulid
Universally Unique Lexicographically Sortable Identifier implementation for Ruby

Official specification page: https://github.com/ulid/spec

<h1 align="center">
	<br>
	<br>
	<img width="360" src="logo.png" alt="ulid">
	<br>
	<br>
	<br>
</h1>

# Universally Unique Lexicographically Sortable Identifier

UUID can be suboptimal for many uses-cases because:

- It isn't the most character efficient way of encoding 128 bits of randomness
- The string format itself is apparently based on the original MAC & time version (UUIDv1 from Wikipedia)
- It provides no other information than randomness

Instead, herein is proposed ULID:

- 128-bit compatibility with UUID
- 1.21e+24 unique ULIDs per millisecond
- Lexicographically sortable!
- Canonically encoded as a 26 character string, as opposed to the 36 character UUID
- Uses Crockford's base32 for better efficiency and readability (5 bits per character)
- Case insensitive
- No special characters (URL safe)

### Installation

```
gem install ulid
```

### Usage

```ruby
require 'ulid'

ULID.generate # 01ARZ3NDEKTSV4RRFFQ69G5FAV
```

**I want to generate a ULID using an arbitrary timestamp**

You can optionally pass a `Time` instance to `ULID.generate` to set an arbitrary timestamp component, i.e. the prefix of the ULID.

```ruby
time_t1 = Time.now
ulid = ULID.generate(time_t1)
```

**I want to generate a ULID using an arbitrary suffix, i.e. without the randomness component**

You can optionally pass a 80-bit hex-encodable `String` on the argument `suffix` to `ULID.generate`. This will replace the randomness component
by the suffix provided. This allows for fully deterministic ULIDs.

```ruby
require 'securerandom'

time = Time.now
an_event_identifier = SecureRandom.uuid
ulid1 = ULID.generate(time, suffix: an_event_identifier)
ulid2 = ULID.generate(time, suffix: an_event_identifier)
ulid1 == ulid2 # true
```

**I want to decode the timestamp portion of an existing ULID value**

You can also decode the timestamp component of a ULID into a `Time` instance (to millisecond precision).

```ruby
time_t1 = Time.new(2022, 1, 4, 6, 3)
ulid = ULID.generate(time_t1)
time_t2 = ULID.decode_time(ulid)
time_t2 == time_t1 # true
```

## Specification

Below is the current specification of ULID as implemented in this repository. *Note: the binary format has not been implemented.*

```
 01AN4Z07BY      79KA1307SR9X4MV3

|----------|    |----------------|
 Timestamp          Randomness
  10 chars           16 chars
   48bits             80bits
   base32             base32
```

### Components

**Timestamp**
- 48 bit integer
- UNIX-time in milliseconds
- Won't run out of space till the year 10895 AD.

**Randomness**
- 80 bits
- Cryptographically secure source of randomness, if possible

### Sorting

The left-most character must be sorted first, and the right-most character sorted last. The default ASCII order is used for sorting.

### Binary Layout and Byte Order

The components are encoded as 16 octets. Each component is encoded with the Most Significant Byte first (network byte order).

```
0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      32_bit_uint_time_high                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     16_bit_uint_time_low      |       16_bit_uint_random      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       32_bit_uint_random                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       32_bit_uint_random                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### String Representation

```
ttttttttttrrrrrrrrrrrrrrrr

where
t is Timestamp
r is Randomness
```

## Test Suite

```
bundle exec rake test
```

### Credits and references:

* https://github.com/ulid/javascript
