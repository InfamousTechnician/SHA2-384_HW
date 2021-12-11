# VHDL_SHA2-384
Simulated and synthesizable versions of SHA-2/384 consuming roughly 15% of an Artix-15's LUTs, and 9% of its flip-flops.

## State
Not hardware proven yet.

## Motivation
Later I'd like to create a HMAC out of this, and since SHA2-384 is not subject to length extension attacks, which a HMAC combats anyway, I thought this may only become an even happier solution. Furthermore 384/4=96 bits of security against quantum computers should still suffice later on.
