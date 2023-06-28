# dnstrace

[![Release](https://github.com/hatamiarash7/dnstrace/actions/workflows/release.yml/badge.svg)](https://github.com/hatamiarash7/dnstrace/actions/workflows/release.yml) ![GitHub release (release name instead of tag name)](https://img.shields.io/github/v/release/hatamiarash7/dnstrace) ![GitHub](https://img.shields.io/github/license/hatamiarash7/dnstrace)

This tool performs a DNS resolution by tracing the delegation path from the root name servers, and by following the CNAME chain. Each query is reported with statistics about all delegated name servers.

## Features

* Follow CNAMEs
* Query all name servers in parallel and report stats for each
* Report about non glued name server lookup time
* Enable DNSSEC query option to better emulate name server queries
* Compute the cold best path as if the resolver started with an empty cache to recurse queried name

![sc](.github/sc.png)

## Usage

```bash
Usage: dnstrace [qtype] <domain>

  -color
     Enable/disable colors (default true)
```

## Install

* Using Golang:

  ```bash
  go install github.com/hatamiarash7/dnstrace@latest
  ```

* Using brew:

  ```bash
  brew install hatamiarash7/tap/dnstrace
  ```

* Using binary:

  Download [binary package](https://github.com/hatamiarash7/dnstrace/releases/latest).
