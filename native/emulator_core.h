#ifndef EMULATOR_CORE_H
#define EMULATOR_CORE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Funções exportadas
void initialize();
bool load_rom(const char* path);
void close_rom();
void reset();
void start_emulation();
uint8_t* get_frame_buffer();
int32_t get_frame_buffer_size();

#ifdef __cplusplus
}
#endif

#endif // EMULATOR_CORE_H
