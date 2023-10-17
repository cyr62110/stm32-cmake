//This prevent name mangling for functions used in C/assembly files.
extern "C"
{
void SysTick_Handler(void) {
}
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "EndlessLoop"
int main(void) {
    while (1) {}
    return 0;
}
#pragma clang diagnostic pop
