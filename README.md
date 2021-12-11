# VHDL_SHA2-384
Simulated and synthesizable versions of SHA-2/384.
- v1: simplest approach consuming roughly 15% of an Artix-15's LUTs, and 9% of its flip-flops.
- v2: K values stored in block RAM, as well as W shifter and A..H compression function separated by an additional register stage. This way the compression needs be started 1 clock cycle later, and the NLFSR finishes the same cycle earlier.

## State
Not hardware proven yet.

## Plans
- Rewrite it so that K values are stored in a block RAM, significantly reducing LUT usage, since now they're in distributed RAM. (done, v2)
- load by 64 bits of data, not parallelly to spare more look-up-tables.

## Motivation
Later I'd like to create a HMAC out of this, and since SHA2-384 is not subject to length extension attacks, which a HMAC combats anyway, I thought this may only become an even happier solution. Furthermore 384/4=96 bits of security against quantum computers should still suffice later on.
