#pragma once

#include <cstdint>

class sidplayfp;

namespace libsidplayfp
{
	bool vm_getSidEnvelopes(sidplayfp& engine, unsigned int sidNum, uint8_t envelopes[3]);
}

