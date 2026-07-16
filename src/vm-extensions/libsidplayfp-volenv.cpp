#include "vm-extensions/libsidplayfp-volenv.h"

#include <algorithm>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <string>
#include <vector>

#include "vm-extensions/libresidfp-volenv.h"

// Keep Visual Music's note-extraction hook out of upstream-looking libsidplayfp
// files. This translation unit deliberately opens private state only here.
#define private public
#include "sidplayfp/sidplayfp.h"
#include "player.h"
#include "builders/residfp-builder/residfp-emu.h"
#undef private

namespace libsidplayfp
{
	bool vm_getSidEnvelopes(sidplayfp& engine, unsigned int sidNum, uint8_t envelopes[3])
	{
		if (!envelopes)
			return false;

		std::fill(envelopes, envelopes + 3, 0);

		if (sidNum >= engine.sidplayer.m_chips.size())
			return false;

		reSIDfpEmu* resid = dynamic_cast<reSIDfpEmu*>(engine.sidplayer.m_chips[sidNum]);
		if (!resid)
			return false;

		reSIDfp::vm_getEnvelopeOutputs(resid->m_sid, envelopes);
		return true;
	}

	bool vm_getSidEnvelopeAttackStates(sidplayfp& engine, unsigned int sidNum, bool attack[3])
	{
		if (!attack)
			return false;

		std::fill(attack, attack + 3, false);

		if (sidNum >= engine.sidplayer.m_chips.size())
			return false;

		reSIDfpEmu* resid = dynamic_cast<reSIDfpEmu*>(engine.sidplayer.m_chips[sidNum]);
		if (!resid)
			return false;

		reSIDfp::vm_getEnvelopeAttackStates(resid->m_sid, attack);
		return true;
	}
}

