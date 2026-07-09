#define MAGIC_ENUM_USE_MODULES 1
#include <cassert>
#include <cctype>

#if USE_IMPORT_STD
import std;
import magic_enum;
#else
#  include <bit>
#  include <bitset>
#  include <cstdint>
#  include <iostream>
#  include <magic_enum/magic_enum.hpp>
#endif

enum class Color { RED = -10, BLUE = 0, GREEN = 10 };

int test() {
  Color c1 = Color::RED;
  std::cout << magic_enum::enum_name(c1) << std::endl;  // RED
  return 0;
}

int main() {
  test();

  for (const std::uint8_t i : {0, 0b11111111, 0b11110000, 0b00011110}) {
    std::cout << "countl_zero( " << std::bitset<8>(i) << " ) = " << std::countl_zero(i) << '\n';
  }
}
