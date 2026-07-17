#pragma once

#include <cstdint>

class sidplayfp;

namespace libsidplayfp
{
	bool vm_getSidEnvelopes(sidplayfp& engine, unsigned int sidNum, uint8_t envelopes[3]);

	//Per-voice "envelope is in ATTACK" flags; a false->true edge means a gate 0->1 write
	//happened since the previous read (see libresidfp's vm_getEnvelopeAttackStates).
	bool vm_getSidEnvelopeAttackStates(sidplayfp& engine, unsigned int sidNum, bool attack[3]);
}

