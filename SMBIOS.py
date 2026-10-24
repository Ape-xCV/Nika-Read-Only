#!/usr/bin/env python3

from pathlib import Path
from uuid import UUID
import argparse, os

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--output", default="smbios.bin")
args = parser.parse_args()

def get_bytes(path):
	try: return Path(path).read_bytes()
	except OSError: return b""

# 1. Table concatenation
data = get_bytes("/sys/firmware/dmi/tables/smbios_entry_point") + get_bytes("/sys/firmware/dmi/tables/DMI")

# 2. Overwrite UUID bytes
if raw := get_bytes("/sys/class/dmi/id/product_uuid").strip():
	data = data.replace(UUID(raw.decode()).bytes_le, os.urandom(16))

# 3. Overwrite SN strings
for attr in ("board_serial", "chassis_serial", "product_serial"):
	if val := get_bytes(f"/sys/class/dmi/id/{attr}").strip():
		data = data.replace(val, b"To Be Filled By O.E.M.")

for entry in Path("/sys/firmware/dmi/entries/").glob("17-*/raw"):
	for token in get_bytes(entry)[2:].split(b'\x00'):
		if len(token) == 8 and token.isalnum():
			data = data.replace(token.lower(), b"00000000").replace(token.upper(), b"00000000")

if data:
	Path(args.output).write_bytes(data)
