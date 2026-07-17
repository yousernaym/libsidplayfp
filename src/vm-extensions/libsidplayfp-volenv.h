#pragma once

#include <cstdint>

class sidplayfp;

namespace libsidplayfp
{
	bool vm_getSidEnvelopes(sidplayfp& engine, unsigned int sidNum, uint8_t envelopes[3]);

	//Per-voice "envelope is in ATTACK" flags; a false->true edge means a gate 0->1 write
	//happened since the previous read (see libresidfp's vm_getEnvelopeAttackStates).
	bool vm_getSidEnvelopeAttackStates(sidplayfp& engine, unsigned int sidNum, bool attack[3]);

	//Restrict all three voices of chip sidNum to one waveform combo (0 = off): a voice only
	//sounds while its control register selects exactly this waveform. Decided per register
	//write inside sidemu, so instruments that alternate waveforms every frame are isolated
	//frame-exactly — engine.mute() cannot do this because it masks *future* writes, which on
	//an alternating voice silences exactly the wrong frames (see sidemu::vmWaveformFilter).
	bool vm_setSidWaveformFilter(sidplayfp& engine, unsigned int sidNum, uint8_t waveform);
}

