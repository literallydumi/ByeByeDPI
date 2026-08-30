# ByeByeDPI

ByeByeDPI is a Windows utility for bypassing naive, stateless DPI
(Deep Packet Inspection) middleboxes that block or throttle traffic by
inspecting the plaintext HTTP request line / Host header or the TLS
ClientHello. It intercepts your own outbound traffic at the packet
level using [WinDivert](https://reqrypt.org/windivert.html) and
rewrites it just enough to confuse simple on-path inspectors, while
leaving the traffic byte-for-byte correct for the real destination
server.

It does not proxy, encrypt, or route your traffic anywhere — it only
reshapes the packets your own machine already sends, on their way out.

## Features

- **TLS ClientHello fragmentation** — splits the ClientHello across
  two TCP segments so the SNI (server name) extension isn't visible
  in a single packet.
- **Fake/decoy packets** — sends a bogus, low-TTL packet immediately
  before the real segment. An on-path inspector that doesn't track
  TTL sees corrupted data; the real destination never receives the
  decoy at all.
- **HTTP request fragmentation** — splits plain HTTP requests across
  two segments.
- **Host header mangling** — mixed-case and extra-space variants of
  the `Host:` header that many naive filters fail to match against
  their blocklists.
- **DNS redirection** — optionally redirects outgoing DNS queries to
  a resolver of your choice (e.g. `1.1.1.1:53`).
- **Live, real stats** — while running, shows a continuously updated
  block of real counters (packets seen, ClientHellos fragmented,
  decoys sent, HTTP requests fragmented, DNS queries redirected) —
  not placeholders.

## Requirements

- Windows 10 or 11, 64-bit.
- Administrator privileges (required to install the WinDivert packet
  filter).

Nothing else needs to be installed. The release package bundles its
own embedded Python interpreter and the `pydivert` library (including
the WinDivert driver files), so there is no separate Python or pip
install step.

## Usage

The simplest way to run it is to double-click **`dnsredir.cmd`** as
Administrator. This starts ByeByeDPI with sane defaults and redirects
DNS to `1.1.1.1:53`.

To run it manually with custom options, open an elevated command
prompt in the project folder and run:

```
python\python.exe byebyedpi.py [options]
```

### Options

| Option | Description |
| --- | --- |
| `--http-port PORT` | Additional plain-HTTP port to watch (repeatable; default: 80) |
| `--https-port PORT` | Additional TLS port to watch (repeatable; default: 443) |
| `--ttl N` | TTL used for the decoy packet (default: 3) |
| `--no-fake` | Disable decoy packet injection |
| `--no-wrong-ack` | Do not flip the ACK flag on the decoy packet |
| `--no-http-frag` | Disable HTTP request fragmentation |
| `--no-mixed-case` | Disable Host header case mangling |
| `--no-host-space` | Disable extra space after `Host:` |
| `--dns-redirect HOST[:PORT]` | Redirect outgoing DNS queries (e.g. `1.1.1.1:53`) |

Stop it at any time with **Ctrl+C** in the console window (closing
the window with the X button instead can leave the WinDivert driver
in a bad state until you reboot).

## How it works

`byebyedpi/core.py` opens a WinDivert handle filtered to outbound
traffic on the configured HTTP/HTTPS ports (plus port 53 if DNS
redirection is enabled). Each intercepted packet is inspected:

- TLS ClientHellos are split into two TCP segments, optionally
  preceded by a decoy packet.
- Plain HTTP requests have their Host header mangled and are
  optionally split into two segments.
- DNS queries are rewritten to point at the configured resolver.

Everything else is passed through untouched.

## Project layout

```
byebyedpi/        Core package (engine, config, CLI)
libs/pydivert/    Vendored pydivert + WinDivert driver files
python/           Embedded Python runtime
tests/            Unit tests for the engine's packet handling
dnsredir.cmd      One-click launcher with DNS redirection enabled
```

## Running the tests

```
python -m tests.test_engine
```

This builds synthetic TLS ClientHello, HTTP request, and DNS query
packets and runs them through the real `Engine._process()` code path,
asserting on the resulting fragment count and stats.

## Disclaimer

This tool is intended for personal use to work around overly broad or
faulty traffic filtering on networks you are authorized to use it on.
You are responsible for complying with the laws and terms of service
that apply to you.


## Warnings
Because of Kaspersky's agreement with the Russian government ByeByeDPI
and other DPI bypassing programs can not bypass DPI blocks if you have
Kaspersky Antivirus installed on your computer.

If you see a warning that says Smart App Control blocked a program that
is not safe to run while opening **dnsredir.cmd**, simply right click
the file, click **Properties**, then click **Unblock File** or **Unblock**.


---

This project is inspired by GoodbyeDPI.
