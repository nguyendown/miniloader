#include <Windows.h>

HMODULE dll = NULL;

BOOL APIENTRY DllMain(HINSTANCE instance, DWORD reason, LPVOID reserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(instance);
        dll = LoadLibrary("b3hm.dll");
    } else if (reason == DLL_PROCESS_DETACH) {
        if (dll != NULL) {
            FreeLibrary(dll);
        }
    }

    return TRUE;
}
