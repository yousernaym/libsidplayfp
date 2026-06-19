/*
 * Hand-maintained config.h for the Visual Music MSVC build of libsidplayfp.
 *
 * Upstream libsidplayfp is autotools-only and generates this file at configure
 * time. The Visual Music fork builds with MSVC instead, so this replacement is
 * force-included (/FI config.h) and gated by HAVE_CONFIG_H, both set in
 * libsidplayfp.vcxproj. It is part of the (build-files-only) fork delta.
 *
 * Only the macros actually referenced by the compiled sources are defined; see
 * the grep in the upgrade plan. No SIMD/endianness/strcasecmp macros are needed
 * because the relevant code takes the _WIN32 path.
 */

#ifndef VM_LIBSIDPLAYFP_CONFIG_H
#define VM_LIBSIDPLAYFP_CONFIG_H

/* C++ standard level. MSVC does not set __cplusplus reliably (it stays at
 * 199711L without /Zc:__cplusplus), so sidcxx11.h cannot detect the standard
 * on its own. The project compiles with /std:c++20; declare the levels here so
 * sidcxx11.h cascades CXX17 -> CXX14 -> CXX11, so only the highest level is
 * declared here (declaring the lower ones too triggers C4005 redefinition). */
#define HAVE_CXX17 1

/* Package identification (PACKAGE*, VERSION; used by SidInfoImpl.h). Generated
 * from config_version.h.in into config_version.h by the GenerateBuildHeaders
 * target in libsidplayfp.vcxproj, with the version read from configure.ac — so a
 * version bump needs no edit here. */
#include "config_version.h"

#endif /* VM_LIBSIDPLAYFP_CONFIG_H */
