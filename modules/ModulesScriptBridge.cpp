/*
 * Generic Chipa module script bridge.
 *
 * When MODULES=1, the scripts target is compiled with AddScripts renamed to
 * AddCoreScripts. This file undefines that build-only macro and restores the
 * public AddScripts entry point, invoking Core scripts first and optional
 * module scripts second.
 *
 * No PlayerBot-specific dependency is allowed in this file.
 */

#ifdef AddScripts
#  undef AddScripts
#endif

void AddCoreScripts();
void AddModulesScripts();

void AddScripts()
{
    AddCoreScripts();
    AddModulesScripts();
}
