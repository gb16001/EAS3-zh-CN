"""Minimal .NET .resources binary parser — reads string entries without deserialising objects.

Used for obfuscated assemblies where System.Resources.ResourceReader fails on
values that reference merged assemblies.
"""
import struct


def read_7bit(buf, pos):
    result = 0
    shift = 0
    while True:
        b = buf[pos]
        pos += 1
        result |= (b & 0x7F) << shift
        if not (b & 0x80):
            break
        shift += 7
    return result, pos


def parse(buf):
    """Return dict of name -> string value (non-string values are skipped)."""
    pos = 0
    magic = struct.unpack_from("<I", buf, pos)[0]
    pos += 4
    if magic != 0xBEEFCACE:
        raise ValueError("bad magic %#x" % magic)
    _header_version = struct.unpack_from("<i", buf, pos)[0]
    pos += 4
    header_size = struct.unpack_from("<i", buf, pos)[0]
    pos += 4
    pos += header_size

    _runtime_version = struct.unpack_from("<i", buf, pos)[0]
    pos += 4
    num_resources = struct.unpack_from("<i", buf, pos)[0]
    pos += 4
    num_types = struct.unpack_from("<i", buf, pos)[0]
    pos += 4

    types = []
    for _ in range(num_types):
        ln, pos = read_7bit(buf, pos)
        types.append(buf[pos:pos + ln].decode("utf-8"))
        pos += ln

    while pos % 8:
        pos += 1

    hashes = struct.unpack_from("<%di" % num_resources, buf, pos)
    pos += 4 * num_resources
    name_positions = struct.unpack_from("<%di" % num_resources, buf, pos)
    pos += 4 * num_resources
    data_offsets = struct.unpack_from("<%di" % num_resources, buf, pos)
    pos += 4 * num_resources
    base = pos

    out = {}
    for i in range(num_resources):
        if not (hashes[i] & 0x80000000):
            # virtual name derived from the type table; not a real key
            continue
        np = base + name_positions[i]
        ln, np = read_7bit(buf, np)
        name = buf[np:np + ln].decode("utf-8")

        dp = base + data_offsets[i]
        type_index, dp = read_7bit(buf, dp)
        if type_index < 0 or type_index >= len(types):
            continue
        if types[type_index] != "System.String":
            continue
        ln, dp = read_7bit(buf, dp)
        out[name] = buf[dp:dp + ln].decode("utf-8")
    return out, types
