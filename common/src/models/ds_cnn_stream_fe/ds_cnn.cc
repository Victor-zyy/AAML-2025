#include "models/ds_cnn_stream_fe/ds_cnn.h"
#include <stdio.h>
#include "menu.h"
#include "models/ds_cnn_stream_fe/ds_cnn_stream_fe.h"
#include "tflite.h"
#include "models/label/label0_board.h"
#include "models/label/label1_board.h"
#include "models/label/label6_board.h"
#include "models/label/label8_board.h"
#include "models/label/label11_board.h"


// Initialize everything once
// deallocate tensors when done
static void ds_cnn_stream_fe_init(void) {
  tflite_load_model(ds_cnn_stream_fe, ds_cnn_stream_fe_len);
}

// TODO: Implement your design here
static void do_init_zeros_input(void) 
{
    puts("Loading zeros input");
    //tflite_load_model(
}

static void do_init_label0(void) 
{

}


static void do_init_label1(void) 
{

}

static void do_init_label6(void) 
{

}

static void do_init_label8(void) 
{

}

static void do_init_label11(void) 
{

}
static struct Menu MENU = {
    "Tests for ds_cnn_stream_fe",
    "ds_cnn_stream_fe",
    {
        MENU_ITEM('1', "Run with zeros input", do_init_zeros_input),
        MENU_ITEM('2', "Run with label0", do_init_label0),
        MENU_ITEM('3', "Run with label1", do_init_label1),
        MENU_ITEM('4', "Run with label6", do_init_label6),
        MENU_ITEM('5', "Run with label8", do_init_label8),
        MENU_ITEM('6', "Run with label11", do_init_label11),
        MENU_END,
    },
};

// For integration into menu system
void ds_cnn_stream_fe_menu() {
  ds_cnn_stream_fe_init();
  menu_run(&MENU);
}

