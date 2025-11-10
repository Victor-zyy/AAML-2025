/*
 * Copyright 2021 The CFU-Playground Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "proj_menu.h"

#include <stdio.h>

#include "cfu.h"
#include "menu.h"

namespace {

// Template Fn
void do_exercise_cfu_with_off(void){
  int time = 100000;
  int32_t off = 0xffffff9a;
  int32_t val1 = 0x66666680;
  int32_t val2 = 0x0af82b81;
  int32_t acc = 0;
  acc = cfu_op0(1, off, 0);
  printf("initial acc : 0x%08lx\r\n", acc);
  cfu_op0(0, val1, val2);
  while (time--)
  {
    /* code */
  }
  acc = cfu_op0(0, 0, 0);

  printf("off : 0x%08lx\r\n", off);
  printf("val1: 0x%08lx\r\n", val1);
  printf("val2: 0x%08lx\r\n", val2);
  printf("acc : 0x%08lx\r\n", acc);
}


void do_check_cfu_off(void){
  int32_t off1 = 0xffffff9a;
  int32_t acc = 0;
  printf("off1 : 0x%08lx\r\n", off1);
  acc = cfu_op0(1, off1, 0);
  printf("initial acc : 0x%08lx\r\n", acc);
  acc = cfu_op0(0, 0xffffff80, 0xffffff81);
  printf("acc : 0x%08lx\r\n", acc);
}
void do_hello_world(void) { puts("Hello, World!!!\n"); }

// Test template instruction
void do_grid_cfu_op0(void) {
  puts("\nExercise CFU Op0\n");
  cfu_op0(1, 0, 0); // initialzie the Inputoffset Register
  printf("a   b-->");
  for (int b = 0; b < 6; b++) {
    printf("%8d", b);
  }
  puts("\n-------------------------------------------------------");
  for (int a = 0; a < 6; a++) {
    printf("%-8d", a);
    for (int b = 0; b < 6; b++) {
      int cfu = cfu_op0(0, a, b);
      printf("%8d", cfu);
    }
    puts("");
  }
  /**
   * Testing for negative values
   */
  // -2 -3 -4 -5
  // -1  2 -3  4 = 2 - 6 + 12 -20 = -12
  int8_t arr[4][4] = {{-1, -2, -3, -4},   //1 -4 + 9 -16 + 10 - 22 + 36 -52 -6 + 16 - 1 + 4 - 9 + 16 = -18
                      {-10, -11, -12, -13},
                      {0, 0, 2, 4,},
                      {1, 2, 3, 4}};
  int8_t filter[4] = { -1, 2, -3, 4}; 
  int32_t acc = 0;
  acc = cfu_op0(1, 0, 0);
  printf("acc : %8ld\r\n", acc);
  for(int i = 0; i < 4; i++ ){
    int32_t a1 = (arr[i][0] & 0xff) | (arr[i][1] & 0xff) << 8 | (arr[i][2] & 0xff) << 16 | (arr[i][3] & 0xff) << 24;
    int32_t a2 = (filter[0] & 0xff) | (filter[1] & 0xff) << 8 | (filter[2] & 0xff) << 16 | (filter[3] & 0xff) << 24;
    acc = cfu_op0(0, a1, a2);
    printf("a1 : 0x%08lx a2 : 0x%08lx \r\n", a1, a2);
    printf("acc : %8ld\r\n", acc);
  } 
}

// Test template instruction
void do_exercise_cfu_op0(void) {
  puts("\nExercise CFU Op0\n");
  int count = 0;
  cfu_op0(1, 0, 0);
  for (int a = -0x71234567; a < 0x68000000; a += 0x10012345) {
    for (int b = -0x7edcba98; b < 0x68000000; b += 0x10770077) {
      int cfu = cfu_op0(0, a, b);
      printf("a: %08x b:%08x cfu=%08x\n", a, b, cfu);
      if (cfu != a) {
        printf("\n***FAIL\n");
        return;
      }
      count++;
    }
  }
  printf("Performed %d comparisons", count);
}

struct Menu MENU = {
    "Project Menu",
    "project",
    {
        MENU_ITEM('0', "exercise cfu op0", do_exercise_cfu_op0),
        MENU_ITEM('r', "cfu op0 check off", do_check_cfu_off),
        MENU_ITEM('g', "grid cfu op0", do_grid_cfu_op0),
        MENU_ITEM('p', "exercise cfu with offset", do_exercise_cfu_with_off),
        MENU_ITEM('h', "say Hello", do_hello_world),
        MENU_END,
    },
};

};  // anonymous namespace

extern "C" void do_proj_menu() { menu_run(&MENU); }
