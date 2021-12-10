# VHDL_SHA2-384
SHA-2 versions working on 64 bits of data: 384 and 512.

## Motivation
Later I'd like to create a HMAC out of this, and since SHA2-384 is not sibject to length extension attacks (which a HMAC combats anyway) I thought this may can only be a happier solution. Furthermore 384/4=96 bits of security against quantum computers should still suffice later on.
